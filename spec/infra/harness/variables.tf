variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "service_name" {}
variable "service_image" {}
variable "service_command" {
  type = list(string)
}
variable "service_task_container_definitions" {}
variable "service_task_network_mode" {}
variable "service_task_pid_mode" {}

variable "service_port" {}
variable "service_desired_count" {}
variable "service_deployment_maximum_percent" {}
variable "service_deployment_minimum_healthy_percent" {}

variable "service_role" {}
variable "service_volumes" {
  type = list(map(string))
}

variable "scheduling_strategy" {}

variable "placement_constraints" {
  type = list(map(string))
}

variable "attach_to_load_balancer" {}
variable "service_elb_name" {}
variable "target_group_arn" {}

variable "register_in_service_discovery" {}
variable "service_discovery_create_registry" {}
variable "service_discovery_namespace_id" {}
variable "service_discovery_registry_arn" {}
variable "service_discovery_record_type" {}

variable "associate_default_security_group" {}
variable "default_security_group_ingress_cidrs" {
  type = list(string)
}
variable "default_security_group_egress_cidrs" {
  type = list(string)
}

variable "include_log_group" {}
variable "log_group_retention" {}
