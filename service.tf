resource "aws_service_discovery_service" "service" {
  count = var.register_in_service_discovery == "yes" ? 1 : 0

  name = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count = var.service_desired_count
  iam_role = var.attach_to_load_balancer == "yes" ? var.ecs_cluster_service_role_arn : null

  deployment_maximum_percent = var.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent

  scheduling_strategy = var.scheduling_strategy

  force_new_deployment = var.force_new_deployment == "yes"

  dynamic "network_configuration" {
    for_each = var.service_task_network_mode == "awsvpc" ? [var.subnet_ids] : []

    content {
      subnets = network_configuration.value
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      type = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "service_registries" {
    for_each = var.register_in_service_discovery == "yes" ? [aws_service_discovery_service.service[0].arn] : []

    content {
      registry_arn = service_registries.value
    }
  }

  dynamic "load_balancer" {
    for_each = var.attach_to_load_balancer == "yes" ? [var.service_elb_name] : []

    content {
      elb_name = load_balancer.value
      target_group_arn = var.target_group_arn
      container_name = coalesce(var.target_container_name, var.service_name)
      container_port = coalesce(var.target_port, var.service_port)
    }
  }
}
