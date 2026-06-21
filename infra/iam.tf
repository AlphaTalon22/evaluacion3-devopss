########################################
# IAM Role - Plano de control EKS (Cluster Role)
########################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  # Política de confianza: permite que el servicio EKS asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-eks-cluster-role"
    Project = var.project_name
  }
}

# Política gestionada por AWS requerida para que EKS pueda administrar el clúster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

########################################
# IAM Role - Nodos worker EKS (Node Role)
########################################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  # Política de confianza: permite que EC2 asuma este rol (los nodos son instancias EC2)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-eks-node-role"
    Project = var.project_name
  }
}

# Políticas gestionadas por AWS requeridas para los nodos worker
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  # Permite al plugin CNI de Amazon VPC gestionar interfaces de red para los pods
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  # Permite a los nodos descargar imágenes desde Amazon ECR
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  # Permite a los nodos enviar logs y métricas a CloudWatch
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_role.name
}

########################################
# IAM Role - Task/Pod execution (para acceder a ECR y Secrets Manager)
########################################
resource "aws_iam_role" "eks_pod_execution_role" {
  name = "${var.project_name}-eks-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-eks-pod-execution-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "pod_ecr_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_pod_execution_role.name
}
