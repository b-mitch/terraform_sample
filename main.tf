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

# Create RDS Instances
resource "aws_db_instance" "woutfh_prod_db" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  identifier        = "woutfh-prod-db"
  allocated_storage = 20
  username          = var.secrets["prod_db_username"]
  password          = var.secrets["prod_db_password"]
  engine_version    = "15.4-R3""

  subnet_ids = [aws_subnet.public_subnet.id]  # Specify the production subnet

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

  subnet_ids = [aws_subnet.private_subnet.id]  # Specify the dev subnet

  tags = {
    Name = "WoutFHDevRDSInstance"
  }
}

# Create Route 53 DNS Record
resource "aws_route53_record" "app_dns" {
  name    = "your_domain_name"
  type    = "A"
  zone_id = "your_zone_id"
  ttl     = "300"
  records = [aws_instance.prod_instance.public_ip]
}

# CodePipline Setup
resource "aws_codepipeline" "woutfh_pipeline" {
  name     = "woutfh-pipeline"
  role_arn = "your_role_arn"

  artifact_store {
    location = "your_bucket_name"
    type     = "S3"
    encryption_key {
      id   = "your_key_id"
      type = "KMS"
    }
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
        Owner      = "your_github_username"
        Repo       = "your_repo_name"
        Branch     = "your_branch_name"
        OAuthToken = "your_oauth_token"
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
        ProjectName = "your_codebuild_project_name"
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
