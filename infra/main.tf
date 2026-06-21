terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source para obtener las AZs disponibles en la región
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source para obtener el Account ID dinámicamente
data "aws_caller_identity" "current" {}
