data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "EKS-vpc"
  }
}

resource "aws_subnet" "eks_sub" {
  count                   = var.sub_count
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_sub_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_vpc_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eks_sub_rt"
  }
}

resource "aws_route_table_association" "rt_association" {
  count          = var.sub_count
  subnet_id      = element(aws_subnet.eks_sub.*.id, count.index)
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "eks_sg" {
  name        = "EKS_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.eks_vpc.id

  dynamic "ingress" {
    for_each = var.sg_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "EKS_sg"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "TERRAFORM_CLUSTER_ROLE"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "EKS_CLUSTER_ROLE"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "service_policy_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "terraform-EKS"
  role_arn = aws_iam_role.eks_role.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_sg.id]
    subnet_ids         = flatten([aws_subnet.eks_sub.*.id])
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy_attach,
    aws_iam_role_policy_attachment.service_policy_attach,
    aws_subnet.eks_sub,
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "TERRAFORM_NODE_ROLE"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "TERRAFORM_NODE_ROLE"
  }
}

resource "aws_iam_role_policy_attachment" "worker_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "CNI_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "CR_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "eks_nodes" {
  count           = var.node_group_count
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group-${count.index + 1}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_sub.*.id
  instance_types  = var.eks_instance_type
  disk_size       = var.node_disk_size

  scaling_config {
    desired_size = var.desired_vm_size
    max_size     = var.max_vm_size
    min_size     = var.min_vm_size
  }

  update_config {
    max_unavailable = var.max_vm_unavailable
  }

  depends_on = [
    aws_iam_role_policy_attachment.CR_policy_attach,
    aws_iam_role_policy_attachment.CNI_policy_attach,
    aws_iam_role_policy_attachment.worker_policy_attach,
  ]
}