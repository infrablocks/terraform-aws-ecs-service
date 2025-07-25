data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "ecs_service" {
  source = "./../../../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.terraform_remote_state.prerequisites.outputs.vpc_id
  subnet_ids = var.subnet_ids

  service_task_container_definitions = var.service_task_container_definitions
  service_task_network_mode = var.service_task_network_mode
  service_task_pid_mode = var.service_task_pid_mode

  service_name = var.service_name
  service_image = var.service_image
  service_command = var.service_command
  service_port = var.service_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = var.service_deployment_maximum_percent
  service_deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent
  service_health_check_grace_period_seconds = var.service_health_check_grace_period_seconds

  service_role = var.service_role
  service_volumes = var.service_volumes

  scheduling_strategy = var.scheduling_strategy

  placement_constraints = var.placement_constraints

  force_new_deployment = var.force_new_deployment

  wait_for_steady_state = var.wait_for_steady_state

  attach_to_load_balancer = var.attach_to_load_balancer
  service_elb_name = var.service_elb_name
  target_group_arn = var.target_group_arn
  target_container_name = var.target_container_name
  target_port = var.target_port

  register_in_service_discovery = var.register_in_service_discovery
  service_discovery_create_registry = var.service_discovery_create_registry
  service_discovery_namespace_id = var.service_discovery_namespace_id
  service_discovery_registry_arn = var.service_discovery_registry_arn
  service_discovery_record_type = var.service_discovery_record_type
  service_discovery_container_name = var.service_discovery_container_name
  service_discovery_container_port = var.service_discovery_container_port

  associate_default_security_group = var.associate_default_security_group
  include_default_ingress_rule = var.include_default_ingress_rule
  include_default_egress_rule = var.include_default_egress_rule
  default_security_group_ingress_cidrs = var.default_security_group_ingress_cidrs
  default_security_group_egress_cidrs = var.default_security_group_egress_cidrs

  include_log_group = var.include_log_group
  log_group_retention = var.log_group_retention

  ecs_cluster_id = data.terraform_remote_state.prerequisites.outputs.cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.prerequisites.outputs.service_role_arn

  use_fargate = var.use_fargate
  service_task_cpu = var.service_task_cpu
  service_task_memory = var.service_task_memory
  service_task_ephemeral_storage = var.service_task_ephemeral_storage
  service_task_operating_system_family = var.service_task_operating_system_family
  service_task_cpu_architecture = var.service_task_cpu_architecture

  task_execution_role_arn = var.task_execution_role_arn
}
