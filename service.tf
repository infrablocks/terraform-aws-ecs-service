resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.service_desired_count
  iam_role        = (var.attach_to_load_balancer == "yes" && var.service_task_network_mode != "awsvpc") ? var.ecs_cluster_service_role_arn : null

  deployment_maximum_percent         = var.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent

  health_check_grace_period_seconds = var.attach_to_load_balancer == "yes" ? var.service_health_check_grace_period_seconds : null

  scheduling_strategy = var.scheduling_strategy

  force_new_deployment = var.force_new_deployment == "yes"

  dynamic "network_configuration" {
    for_each = var.service_task_network_mode == "awsvpc" ? [var.subnet_ids] : []

    content {
      subnets         = network_configuration.value
      security_groups = [aws_security_group.task.0.id]
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "service_registries" {
    for_each = var.register_in_service_discovery == "yes" ? [var.service_discovery_create_registry == "yes" ? aws_service_discovery_service.service[0].arn : var.service_discovery_registry_arn] : []

    content {
      registry_arn   = service_registries.value
      container_name = var.service_discovery_record_type == "SRV" ? coalesce(var.service_discovery_container_name, var.service_name) : null
      container_port = var.service_discovery_record_type == "SRV" ? coalesce(var.service_discovery_container_port, var.service_port) : null
    }
  }

  dynamic "load_balancer" {
    for_each = var.attach_to_load_balancer == "yes" ? [coalesce(var.target_group_arn, var.service_elb_name)] : []

    content {
      elb_name         = var.service_elb_name
      target_group_arn = var.target_group_arn
      container_name   = coalesce(var.target_container_name, var.service_name)
      container_port   = coalesce(var.target_port, var.service_port)
    }
  }
}
