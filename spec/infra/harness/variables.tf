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

variable "include_log_group" {}
