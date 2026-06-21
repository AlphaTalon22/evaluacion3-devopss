########################################
# Clúster EKS
########################################
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access  = true   # API server accesible desde internet (para GitHub Actions)
    endpoint_private_access = true   # También accesible desde dentro de la VPC
  }

  # Habilitar logs del plano de control hacia CloudWatch
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name    = var.cluster_name
    Project = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

########################################
# Node Group - Nodos worker EC2
########################################
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # Nodos en subredes privadas (más seguro; acceso a internet vía NAT)
  subnet_ids = aws_subnet.private[*].id

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Permite actualizaciones de los nodos sin downtime
  update_config {
    max_unavailable = 1
  }

  # Tipo de capacidad: ON_DEMAND para estabilidad
  capacity_type = "ON_DEMAND"

  # Tipo de disco de los nodos
  disk_size = 20

  tags = {
    Name    = "${var.project_name}-worker-node"
    Project = var.project_name
    # Requerido por el Cluster Autoscaler (si se usa en el futuro)
    "k8s.io/cluster-autoscaler/enabled"           = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]
}
