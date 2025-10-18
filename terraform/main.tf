terraform {

  cloud {

    organization = "ISIMM-TEST"

    workspaces {
      name = "cloud-project"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Set the AWS region to US East (N. Virginia)
}

module "main" {
  source                 = "./modules"
  vpc_availability_zones = ["us-east-1a", "us-east-1b"]
  db_name                = "test_db"
  db_user                = "ahmed"
  db_pass                = "password"
}
