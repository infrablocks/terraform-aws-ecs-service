terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.59"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2"
    }
  }
}
