locals {
  s3_tf_state     = "${var.project_name}-${var.environment}-directive-tf-state"
  global_tf_state = "tf-infra/global/terraform.tfstate"
  dynamo_tf_state = "${var.project_name}-${var.environment}-tf-state-locking"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env       = var.environment
      Project   = var.project_name
      Terraform = true
    }
  }
}

