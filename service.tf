resource "aws_ecs_service" "service" {
  propagate_tags = "TASK_DEFINITION"

  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = local.service_desired_count
  iam_role        = (local.attach_to_load_balancer == "yes" && local.service_task_network_mode != "awsvpc") ? var.ecs_cluster_service_role_arn : null

  deployment_maximum_percent         = local.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = local.service_deployment_minimum_healthy_percent

  health_check_grace_period_seconds = local.attach_to_load_balancer == "yes" ? local.service_health_check_grace_period_seconds : null

  scheduling_strategy = local.scheduling_strategy

  force_new_deployment = local.force_new_deployment == "yes"

  dynamic "network_configuration" {
    for_each = local.service_task_network_mode == "awsvpc" ? [local.subnet_ids] : []

    content {
      subnets         = network_configuration.value
      security_groups = compact([try(aws_security_group.task.0.id, "")])
    }
  }

  dynamic "placement_constraints" {
    for_each = local.placement_constraints

    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "service_registries" {
    for_each = local.register_in_service_discovery == "yes" ? [local.service_discovery_create_registry == "yes" ? aws_service_discovery_service.service[0].arn : local.service_discovery_registry_arn] : []

    content {
      registry_arn   = service_registries.value
      container_name = local.service_discovery_record_type == "SRV" ? coalesce(local.service_discovery_container_name, var.service_name) : null
      container_port = local.service_discovery_record_type == "SRV" ? coalesce(local.service_discovery_container_port, var.service_port) : null
    }
  }

  dynamic "load_balancer" {
    for_each = local.attach_to_load_balancer == "yes" ? [coalesce(local.target_group_arn, local.service_elb_name)] : []

    content {
      elb_name         = local.target_group_arn == "" ? local.service_elb_name : null
      target_group_arn = local.target_group_arn == "" ? null : local.target_group_arn
      container_name   = coalesce(local.target_container_name, var.service_name)
      container_port   = coalesce(local.target_port, var.service_port)
    }
  }
}
