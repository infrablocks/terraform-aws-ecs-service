locals {
  service_task_container_definitions_template = coalesce(
    var.service_task_container_definitions,
  file("${path.module}/container-definitions/service.json.tpl"))
  resolved_service_task_container_definitions = replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  local.service_task_container_definitions_template,
                "$${name}", var.service_name),
              "$${image}", var.service_image),
            "$${command}", jsonencode(var.service_command)),
          "$${port}", var.service_port),
        "$${region}", var.region),
      "$${log_group}", var.include_log_group ? aws_cloudwatch_log_group.service[0].name : ""),
    "$${cpu}", var.service_task_cpu),
  "$${memory}", var.service_task_memory)
}

resource "aws_iam_role" "default_task_execution_role" {
  description = "default-task-execution-role-${var.component}-${var.deployment_identifier}-${var.service_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Sid = ""
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "default_task_execution_policy" {
  statement {
    sid = "1"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role_policy" "default_task_execution_role_policy" {
  role   = aws_iam_role.default_task_execution_role.id
  policy = data.aws_iam_policy_document.default_task_execution_policy.json
}

resource "aws_ecs_task_definition" "service" {
  family                = "${var.component}-${var.service_name}-${var.deployment_identifier}"
  container_definitions = local.resolved_service_task_container_definitions

  network_mode = var.use_fargate ? "awsvpc" : var.service_task_network_mode
  pid_mode     = var.service_task_pid_mode

  task_role_arn      = var.service_role
  execution_role_arn = var.use_fargate ? (var.task_execution_role_arn == null ? aws_iam_role.default_task_execution_role.arn : var.task_execution_role_arn) : null

  requires_compatibilities = var.use_fargate ? ["FARGATE"] : null
  cpu                      = var.use_fargate ? var.service_task_cpu : null
  memory                   = var.use_fargate ? var.service_task_memory : null

  runtime_platform {
    operating_system_family = var.use_fargate ? var.service_task_operating_system_family : null
    cpu_architecture        = var.use_fargate ? var.service_task_cpu_architecture : null
  }

  dynamic "ephemeral_storage" {
    for_each = var.use_fargate && var.service_task_ephemeral_storage != null ? [var.service_task_ephemeral_storage] : []
    content {
      size_in_gib = ephemeral_storage.value
    }
  }

  dynamic "volume" {
    for_each = var.service_volumes
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)
    }
  }
}
