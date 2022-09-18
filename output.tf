output "availability_zones" {
  description = "to get the availability zones in the region"
  value       = aws_subnet.eks_sub.*.availability_zone
}

output "eks_subnets" {
  description = "to get the subnet"
  value       = aws_eks_cluster.eks_cluster.vpc_config.*.subnet_ids
}

output "endpoint" {
  description = "to get the eks cluster endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  description = "to get the kubeconfig certificate authority data"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}