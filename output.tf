output "availability_zones" {
  value = aws_subnet.eks_sub.*.availability_zone
}

output "eks_subnets" {
  value = aws_eks_cluster.eks_cluster.vpc_config.*.subnet_ids
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}