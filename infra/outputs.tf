########################################
# Outputs - valores exportados tras aplicar Terraform
# Útiles para configurar kubectl y el pipeline CI/CD
########################################

output "cluster_name" {
  description = "Nombre del clúster EKS creado"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint del API server de EKS (usado por kubectl)"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA del clúster (necesario para autenticación kubectl)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR (usar en el pipeline CI/CD)"
  value = {
    for name, repo in aws_ecr_repository.repos : name => repo.repository_url
  }
}

output "aws_account_id" {
  description = "ID de la cuenta AWS (útil para construir URLs de ECR)"
  value       = data.aws_caller_identity.current.account_id
}

output "kubectl_config_command" {
  description = "Comando para configurar kubectl y conectarse al clúster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
