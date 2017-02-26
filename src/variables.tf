variable "component" {}
variable "deployment_identifier" {}

variable "vpc_id" {}

variable "allowed_cidrs" {
  default = ""
}

variable "private_network_cidr" {
  default = "10.0.0.0/8"
}

variable "service_task_definition" {
  default = ""
}

variable "service_name" {
  default = ""
}

variable "service_image" {
}
variable "service_command" {
  type = "list"
  default = []
}
variable "service_port" {
  default = ""
}

variable "region" {}

variable "service_certificate_arn" {}

variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

variable "ecs_cluster_id" {}
variable "ecs_cluster_service_role_arn" {}
variable "ecs_cluster_log_group" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "elb_health_check_target" {
  default = "HTTP:80/health"
}
variable "elb_internal" {
  default = true
}
variable "elb_https_allow_cidrs" {
  default = ""
}
