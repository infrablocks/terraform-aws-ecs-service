data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "ecs_service" {
  source = "../../../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.terraform_remote_state.prerequisites.outputs.vpc_id

  service_task_container_definitions = var.service_task_container_definitions
  service_task_network_mode = var.service_task_network_mode

  service_name = var.service_name
  service_image = var.service_image
  service_command = var.service_command
  service_port = var.service_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = var.service_deployment_maximum_percent
  service_deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent

  service_role = var.service_role
  service_volumes  =var.service_volumes

  scheduling_strategy = var.scheduling_strategy

  placement_constraints = var.placement_constraints

  attach_to_load_balancer = var.attach_to_load_balancer
  service_elb_name = var.service_elb_name
  target_group_arn = var.target_group_arn

  include_log_group = var.include_log_group

  ecs_cluster_id = data.terraform_remote_state.prerequisites.outputs.cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.prerequisites.outputs.service_role_arn
}
