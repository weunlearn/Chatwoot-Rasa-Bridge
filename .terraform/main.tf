terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "remote" {
    organization = "WeUnlearn"

    workspaces {
      name = "rasa-bridge"
    }
  }
}


variable "aws-region" {
  default     = "ap-south-1"
  description = "AWS default region"
}
variable "aws-profile" {
  default     = "default"
  description = "AWS profile"
}
provider "aws" {
  profile = var.aws-profile
  region  = var.aws-region
}
