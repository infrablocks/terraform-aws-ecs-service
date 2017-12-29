provider "aws" {
  region = "${var.region}"
  version = "1.2"
}

provider "template" {
  version = "~> 1.0"
}
