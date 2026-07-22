terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "devsecops-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner_email
      CostCenter  = "learning"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# ==================== NETWORKING ====================
module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-${var.environment}"
  cidr               = var.vpc_cidr
  azs                = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = var.common_tags
}

# ==================== SECURITY ====================
module "security" {
  source = "../../modules/security"

  name_prefix = "${var.project_name}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  alb_arn     = module.ecs.alb_arn

  enable_guardduty   = var.enable_guardduty
  enable_securityhub = var.enable_securityhub
  enable_config      = var.enable_config

  tags = var.common_tags
}

# ==================== ECS APPLICATION ====================
module "ecs" {
  source = "../../modules/ecs"

  name_prefix     = "${var.project_name}-${var.environment}"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  container_image = var.container_image
  container_port  = var.container_port
  desired_count   = var.desired_count
  cpu             = var.cpu
  memory          = var.memory

  enable_execute_command = var.enable_execute_command

  secrets_arn = aws_secretsmanager_secret.app.arn

  tags = var.common_tags
}

# ==================== OBSERVABILITY ====================
module "observability" {
  source = "../../modules/observability"

  name_prefix = "${var.project_name}-${var.environment}"

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  alb_arn_suffix   = module.ecs.alb_arn_suffix

  enable_xray        = var.enable_xray
  log_retention_days = var.log_retention_days

  tags = var.common_tags
}

# ==================== SECRETS MANAGEMENT ====================
resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.project_name}-${var.environment}-app-secrets"
  description             = "Application secrets for ${var.environment}"
  recovery_window_in_days = 0 # Force delete for learning (use 7-30 in prod)

  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    database_url = "postgresql://localhost:5432/app"
    api_key      = "placeholder-replace-in-console"
    jwt_secret   = "placeholder-rotate-me"
  })
}

# Auto-rotation (commented out for free tier - requires Lambda)
# resource "aws_secretsmanager_secret_rotation" "app" {
#   secret_id           = aws_secretsmanager_secret.app.id
#   rotation_lambda_arn = aws_lambda_function.rotation.arn
#   rotation_rules {
#     automatically_after_days = 30
#   }
# }

# ==================== ECR REPOSITORY ====================
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # For learning environment

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.common_tags
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# ==================== IAM ROLES FOR CI/CD ====================
# OIDC Provider for GitHub Actions (no long-lived credentials)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4e98bab03faadb97b34396831e3780aea1", # GitHub's thumbprint
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"  # Backup
  ]

  tags = var.common_tags
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_ecs" {
  name = "ecs-deploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "iam:PassRole"
      ]
      Resource = "*"
    }]
  })
}

# ==================== OUTPUTS ====================