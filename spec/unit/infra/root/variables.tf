variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "service_name" {}
variable "service_image" {
  default = null
}
variable "service_command" {
  type    = list(string)
  default = null
}
variable "service_task_container_definitions" {
  default = null
}
variable "service_task_network_mode" {
  default = null
}
variable "service_task_pid_mode" {
  default = null
}

variable "service_port" {
  default = null
}
variable "service_desired_count" {
  type    = number
  default = null
}
variable "service_deployment_maximum_percent" {
  type    = number
  default = null
}
variable "service_deployment_minimum_healthy_percent" {
  type    = number
  default = null
}
variable "service_health_check_grace_period_seconds" {
  type    = number
  default = null
}

variable "service_role" {
  default = null
}
variable "service_volumes" {
  type    = list(map(string))
  default = null
}

variable "scheduling_strategy" {
  default = null
}

variable "placement_constraints" {
  type    = list(map(string))
  default = null
}

variable "attach_to_load_balancer" {
  type    = bool
  default = null
}
variable "service_elb_name" {
  default = null
}
variable "target_group_arn" {
  default = null
}
variable "target_container_name" {
  default = null
}
variable "target_port" {
  default = null
}

variable "register_in_service_discovery" {
  type    = bool
  default = null
}
variable "service_discovery_create_registry" {
  type    = bool
  default = null
}
variable "service_discovery_namespace_id" {
  default = null
}
variable "service_discovery_registry_arn" {
  default = null
}
variable "service_discovery_record_type" {
  default = null
}
variable "service_discovery_container_name" {
  default = null
}
variable "service_discovery_container_port" {
  default = null
}

variable "associate_default_security_group" {
  type    = bool
  default = null
}
variable "include_default_ingress_rule" {
  type    = bool
  default = null
}
variable "include_default_egress_rule" {
  type    = bool
  default = null
}
variable "default_security_group_ingress_cidrs" {
  type    = list(string)
  default = null
}
variable "default_security_group_egress_cidrs" {
  type    = list(string)
  default = null
}

variable "include_log_group" {
  type    = bool
  default = null
}
variable "log_group_retention" {
  type    = number
  default = null
}

variable "force_new_deployment" {
  type    = bool
  default = null
}
variable "wait_for_steady_state" {
  type    = bool
  default = null
}
