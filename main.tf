terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "woutfh_main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create Public Subnet
resource "aws_subnet" "woutfh_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Create Private Subnet
resource "aws_subnet" "woutfh_private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
}

# Create EC2 Instances
resource "aws_instance" "woutfh_prod_instance" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.woutfh_public_subnet.id

  # Use remote-exec provisioner to install Ansible
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
    ]
  }
}

resource "aws_instance" "woutfh_dev_instance" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.woutfh_private_subnet.id

  # Use remote-exec provisioner to install Ansible
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
    ]
  }
}

variable "secrets" {
  type        = map
  description = "Map of secret values"
}

# Create RDS Instances
resource "aws_db_instance" "woutfh_prod_db" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  identifier        = "woutfh-prod-db"
  allocated_storage = 20
  username          = var.secrets["prod_db_username"]
  password          = var.secrets["prod_db_password"]
  engine_version    = "15.4-R3""

  subnet_ids = [aws_subnet.woutfh_public_subnet.id]  # Specify the production subnet

  tags = {
    Name = "WoutFHProductionRDSInstance"
  }
}

resource "aws_db_instance" "woutfh_dev_db" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  identifier        = "woutfh-dev-db"
  allocated_storage = 20
  username          = var.secrets["dev_db_username"]
  password          = var.secrets["dev_db_password"]
  engine_version    = "15.4-R3""

  subnet_ids = [aws_subnet.woutfh_private_subnet.id]  # Specify the dev subnet

  tags = {
    Name = "WoutFHDevRDSInstance"
  }
}

resource aws_route53_zone "woutfh_zone" {
  name = "workoutfh.com"
}

# Create Route 53 DNS Record
resource "aws_route53_record" "woutfh_dns" {
  name    = "www"
  type    = "A"
  zone_id = "aws_route53_zone.woutfh_zone.zone_id"
  ttl     = "300"
  records = [aws_instance.woutfh_prod_instance.public_ip]
}

# IAM role for CodeBuild to assume during the build and deploy stages
resource "aws_iam_role" "woutfh_codebuild_role" {
  name = "woutfh-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com",
        },
      },
    ],
  })
}

# CodeBuild project for the build stage (dev)
resource "aws_codebuild_project" "build_dev_project" {
  name          = "build-dev-project"
  service_role  = aws_iam_role.woutfh_codebuild_role.arn
  environment   = "linux_container"
  source {
    type = "NO_SOURCE"
  }
  buildspec = file("buildspec_dev.yml")  # Create a buildspec file for the dev environment
}

# CodeBuild project for the deploy stage (prod)
resource "aws_codebuild_project" "deploy_prod_project" {
  name          = "deploy-prod-project"
  service_role  = aws_iam_role.woutfh_codebuild_role.arn
  environment   = "linux_container"
  source {
    type = "NO_SOURCE"
  }
  buildspec = file("buildspec_prod.yml")  # Create a buildspec file for the prod environment
}

# CodePipline Setup
resource "aws_codepipeline" "woutfh_pipeline" {
  name     = "woutfh-pipeline"
  role_arn = "your_role_arn"

  artifact_store {
    location = "your_bucket_name"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = var.secrets["github_username"]
        Repo       = var.secrets["github_repo"]
        Branch     = "main"
        SecretName = var.secrets["github_token"]
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName = "woutfh-build-project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ClusterName = "your_ecs_cluster_name"
        ServiceName = "your_ecs_service_name"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Security Group rules (customize as needed)

# IAM roles and policies (customize as needed)
