provider "aws" {
  region = var.region
  version = "~> 3.2"
}

provider "template" {
  version = "~> 2.0"
}
