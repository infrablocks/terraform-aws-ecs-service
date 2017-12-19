variable "region" {}
variable "vpc_cidr" {}
variable "availability_zones" {}
variable "private_network_cidr" {}

variable "component" {}
variable "deployment_identifier" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "cluster_name" {}
variable "cluster_instance_ssh_public_key_path" {}
variable "cluster_instance_type" {}

variable "cluster_minimum_size" {}
variable "cluster_maximum_size" {}
variable "cluster_desired_capacity" {}

variable "service_name" {}
variable "service_image" {}
variable "service_command" {
  type = "list"
}
variable "service_task_container_definitions" {}
variable "service_task_network_mode" {}

variable "service_port" {}
variable "service_desired_count" {}
variable "service_deployment_maximum_percent" {}
variable "service_deployment_minimum_healthy_percent" {}

variable "service_certificate_body" {}
variable "service_certificate_private_key" {}

variable "service_role" {}
variable "service_volumes" {
  type = "list"
}

variable "attach_to_load_balancer" {}

variable "elb_internal" {}
variable "elb_health_check_target" {}
variable "elb_https_allow_cidrs" {}

variable "infrastructure_events_bucket" {}
