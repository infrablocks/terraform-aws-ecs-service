locals {
  # default for cases when `null` value provided, meaning "use default"
  subnet_ids = var.subnet_ids == null ? [] : var.subnet_ids

  service_task_container_definitions         = var.service_task_container_definitions == null ? "" : var.service_task_container_definitions
  service_task_network_mode                  = var.service_task_network_mode == null ? "bridge" : var.service_task_network_mode
  service_image                              = var.service_image == null ? "" : var.service_image
  service_command                            = var.service_command == null ? [] : var.service_command
  service_desired_count                      = var.service_desired_count == null ? 3 : var.service_desired_count
  service_role                               = var.service_role == null ? "" : var.service_role
  service_volumes                            = var.service_volumes == null ? [] : var.service_volumes
  service_deployment_maximum_percent         = var.service_deployment_maximum_percent == null ? 200 : var.service_deployment_maximum_percent
  service_deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent == null ? 50 : var.service_deployment_minimum_healthy_percent
  service_health_check_grace_period_seconds  = var.service_health_check_grace_period_seconds == null ? 0 : var.service_health_check_grace_period_seconds

  scheduling_strategy   = var.scheduling_strategy == null ? "REPLICA" : var.scheduling_strategy
  placement_constraints = var.placement_constraints == null ? [] : var.placement_constraints
  force_new_deployment  = var.force_new_deployment == null ? "no" : var.force_new_deployment
  wait_for_steady_state  = var.wait_for_steady_state == null ? false : var.wait_for_steady_state

  attach_to_load_balancer = var.attach_to_load_balancer == null ? "yes" : var.attach_to_load_balancer
  service_elb_name        = var.service_elb_name == null ? "" : var.service_elb_name
  target_group_arn        = var.target_group_arn == null ? "" : var.target_group_arn
  target_container_name   = var.target_container_name == null ? "" : var.target_container_name
  target_port             = var.target_port == null ? "" : var.target_port

  register_in_service_discovery     = var.register_in_service_discovery == null ? "no" : var.register_in_service_discovery
  service_discovery_create_registry = var.service_discovery_create_registry == null ? "yes" : var.service_discovery_create_registry
  service_discovery_namespace_id    = var.service_discovery_namespace_id == null ? "" : var.service_discovery_namespace_id
  service_discovery_registry_arn    = var.service_discovery_registry_arn == null ? "" : var.service_discovery_registry_arn
  service_discovery_record_type     = var.service_discovery_record_type == null ? "SRV" : var.service_discovery_record_type
  service_discovery_container_name  = var.service_discovery_container_name == null ? "" : var.service_discovery_container_name
  service_discovery_container_port  = var.service_discovery_container_port == null ? "" : var.service_discovery_container_port

  associate_default_security_group     = var.associate_default_security_group == null ? "yes" : var.associate_default_security_group
  include_default_ingress_rule         = var.include_default_ingress_rule == null ? "yes" : var.include_default_ingress_rule
  include_default_egress_rule          = var.include_default_egress_rule == null ? "yes" : var.include_default_egress_rule
  default_security_group_ingress_cidrs = var.default_security_group_ingress_cidrs == null ? [
    "10.0.0.0/8"
  ] : var.default_security_group_ingress_cidrs
  default_security_group_egress_cidrs  = var.default_security_group_egress_cidrs == null ? [
    "0.0.0.0/0"
  ] : var.default_security_group_egress_cidrs

  include_log_group   = var.include_log_group == null ? "yes" : var.include_log_group
  log_group_retention = var.log_group_retention == null ? 0 : var.log_group_retention
}
