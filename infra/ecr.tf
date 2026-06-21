########################################
# Repositorios ECR para las imágenes Docker
########################################
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.ecr_repos)

  name                 = each.value
  image_tag_mutability = "MUTABLE" # Permite sobreescribir el tag :latest

  # Escaneo automático de vulnerabilidades al hacer push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Forzar que las imágenes solo se suban con HTTPS (cifrado en tránsito)
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name    = each.value
    Project = var.project_name
  }
}

########################################
# Política de ciclo de vida: mantener solo las últimas 10 imágenes
# para no consumir almacenamiento innecesario en ECR
########################################
resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Eliminar imágenes no etiquetadas con más de 1 día"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Conservar solo las últimas 10 imágenes etiquetadas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "sha-"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
