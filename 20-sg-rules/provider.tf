terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}
# state file code should be written inside provider so that it can understand that we are using resouces
terraform {
  backend "s3" {
    bucket = "dharma-90"
    key    = "roboshop-rules.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true # will enable locking
  }
}


provider "aws" {
  region = "us-east-1"
}