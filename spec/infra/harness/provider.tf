provider "aws" {
  region = "${var.region}"
  version = "1.41"
}

provider "template" {
  version = "~> 1.0"
}
