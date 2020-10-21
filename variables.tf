variable "region" {
  description = "The region into which to deploy the service."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the service."
  type        = string
}
variable "subnet_ids" {
  description = "The IDs of the subnets in which to create ENIs when the service task network mode is \"awsvpc\"."
  type        = list(string)
  default     = []
}

variable "component" {
  description = "The component this service will contain."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "service_task_container_definitions" {
  description = "A template for the container definitions in the task."
  default     = ""
  type        = string
}
variable "service_task_network_mode" {
  description = "The network mode used for the containers in the task."
  default     = "bridge"
  type        = string
}
variable "service_task_pid_mode" {
  description = "The process namespace used for the containers in the task."
  default     = null
  type        = string
}

variable "service_name" {
  description = "The name of the service being created."
  type        = string
}
variable "service_image" {
  description = "The docker image (including version) to deploy."
  default     = ""
  type        = string
}
variable "service_command" {
  description = "The command to run to start the container."
  type        = list(string)
  default     = []
}
variable "service_port" {
  description = "The port the containers will be listening on."
  type        = string
  default     = ""
}

variable "service_desired_count" {
  description = "The desired number of tasks in the service."
  type        = number
  default     = 3
}
variable "service_deployment_maximum_percent" {
  description = "The maximum percentage of the desired count that can be running."
  type        = number
  default     = 200
}
variable "service_deployment_minimum_healthy_percent" {
  description = "The minimum healthy percentage of the desired count to keep running."
  type        = number
  default     = 50
}

variable "attach_to_load_balancer" {
  description = "Whether or not this service should attach to a load balancer (\"yes\" or \"no\")."
  type        = string
  default     = "yes"
}
variable "service_elb_name" {
  description = "The name of the ELB to configure to point at the service containers."
  type        = string
  default     = ""
}
variable "target_group_arn" {
  description = "The arn of the target group to point at the service containers."
  type        = string
  default     = ""
}
variable "target_container_name" {
  description = "The name of the container to which the load balancer should route traffic. Defaults to the service_name."
  type        = string
  default     = ""
}
variable "target_port" {
  description = "The port to which the load balancer should route traffic. Defaults to the service_port."
  type        = string
  default     = ""
}

variable "register_in_service_discovery" {
  description = "Whether or not this service should be registered in service discovery (\"yes\" or \"no\")."
  type        = string
  default     = "no"
}
variable "service_discovery_create_registry" {
  description = "Whether or not to create a service discovery registry for this service (\"yes\" or \"no\")."
  type        = string
  default     = "yes"
}
variable "service_discovery_namespace_id" {
  description = "The ID of the service discovery namespace in which to create the service discovery registry. Required if service_discovery_create_registry is \"yes\"."
  type        = string
  default     = ""
}
variable "service_discovery_registry_arn" {
  description = "The ARN of the service discovery registry into which to register the service. Required if service_discovery_create_registry is \"no\"."
  type        = string
  default     = ""
}
variable "service_discovery_record_type" {
  description = "The type of record to create when registering the service in service discovery."
  type        = string
  default     = "SRV"
}
variable "service_discovery_container_name" {
  description = "The container name to use when registering the service in service discovery. Defaults to the service name."
  type        = string
  default     = ""
}
variable "service_discovery_container_port" {
  description = "The container port to use when registering the service in service discovery. Defaults to the service port."
  type        = string
  default     = ""
}

variable "associate_default_security_group" {
  description = "Whether or not to create and associate a default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "include_default_ingress_rule" {
  description = "Whether or not to include the default ingress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "include_default_egress_rule" {
  description = "Whether or not to include the default egress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "default_security_group_ingress_cidrs" {
  description = "The CIDRs allowed access to containers when using the default security group."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
variable "default_security_group_egress_cidrs" {
  description = "The CIDRs accessible from containers when using the default security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_role" {
  description = "The ARN of the service task role to use."
  type        = string
  default     = ""
}
variable "service_volumes" {
  description = "A list of volumes to make available to the containers in the service."
  type        = list(map(string))
  default     = []
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for this service (\"REPLICA\" or \"DAEMON\")."
  type        = string
  default     = "REPLICA"
}

variable "placement_constraints" {
  description = "A list of placement constraints for the service."
  type        = list(map(string))
  default     = []
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster in which to deploy the service."
  type        = string
}
variable "ecs_cluster_service_role_arn" {
  description = "The ARN of the IAM role to provide to ECS to manage the service."
  type        = string
}

variable "include_log_group" {
  description = "Whether or not to create a log group for the service (\"yes\" or \"no\"). Defaults to \"yes\"."
  type        = string
  default     = "yes"
}

variable "force_new_deployment" {
  description = "Whether or not to force a new deployment of the service (\"yes\" or \"no\"). Defaults to \"no\"."
  type        = string
  default     = "no"
}
