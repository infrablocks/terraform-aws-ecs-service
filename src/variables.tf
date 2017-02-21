variable "component" {}
variable "deployment_identifier" {}

variable "vpc_id" {}

variable "allowed_cidrs" {
  default = ""
}

variable "private_network_cidr" {
  default = "10.0.0.0/8"
}
