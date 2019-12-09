provider "aws" {
  region = var.region
  version = "~> 2.7"
}

provider "template" {
  version = "~> 2.0"
}
