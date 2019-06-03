variable "region" {
  description = "The region into which to deploy the service."
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the service."
}

variable "component" {
  description = "The component this service will contain."
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "service_task_container_definitions" {
  description = "A template for the container definitions in the task."
  default = ""
}
variable "service_task_network_mode" {
  description = "The network mode used for the containers in the task."
  default = "bridge"
}

variable "service_name" {
  description = "The name of the service being created."
}
variable "service_image" {
  description = "The docker image (including version) to deploy."
  default = ""
}
variable "service_command" {
  description = "The command to run to start the container."
  type = "list"
  default = []
}
variable "service_port" {
  description = "The port the containers will be listening on."
  default = ""
}

variable "service_desired_count" {
  description = "The desired number of tasks in the service."
  default = 3
}
variable "service_deployment_maximum_percent" {
  description = "The maximum percentage of the desired count that can be running."
  default = 200
}
variable "service_deployment_minimum_healthy_percent" {
  description = "The minimum healthy percentage of the desired count to keep running."
  default = 50
}
variable "attach_to_load_balancer" {
  description = "Whether or not this service should attach to a load balancer (\"yes\" or \"no\")."
  default = "yes"
}
variable "service_elb_name" {
  description = "The name of the ELB to configure to point at the service containers."
  default = ""
}
variable "target_group_arn" {
  description = "The arn of the target group to point at the service containers."
  default = ""
}
variable "service_role" {
  description = "The ARN of the service task role to use."
  default = ""
}
variable "service_volumes" {
  description = "A list of volumes to make available to the containers in the service."
  type = "list"
  default = []
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for this service (\"REPLICA\" or \"DAEMON\")."
  default = "REPLICA"
}

variable "placement_constraints" {
  description = "A list of placement constraints for the service."
  type = "list"
  default = []
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster in which to deploy the service."
}
variable "ecs_cluster_service_role_arn" {
  description = "The ARN of the IAM role to provide to ECS to manage the service."
}
