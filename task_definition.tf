locals {
  service_task_container_definitions_template = coalesce(
    local.service_task_container_definitions,
    file("${path.module}/container-definitions/service.json.tpl"))
  resolved_service_task_container_definitions = replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              local.service_task_container_definitions_template,
              "$${name}", var.service_name),
            "$${image}", local.service_image),
          "$${command}", jsonencode(local.service_command)),
        "$${port}", var.service_port),
      "$${region}", var.region),
    "$${log_group}", local.include_log_group == "yes" ? aws_cloudwatch_log_group.service[0].name : "")
}

resource "aws_ecs_task_definition" "service" {
  family                = "${var.component}-${var.service_name}-${var.deployment_identifier}"
  container_definitions = local.resolved_service_task_container_definitions

  network_mode = local.service_task_network_mode
  pid_mode     = var.service_task_pid_mode

  task_role_arn = local.service_role

  dynamic "volume" {
    for_each = local.service_volumes
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)
    }
  }
}
