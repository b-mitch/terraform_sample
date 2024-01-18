terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "woutfh-terraform-remote-state"
    key    = "terraform.tfstate.dev"
    region = "us-east-1"
    profile = "terraform-user"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform-user"
}
