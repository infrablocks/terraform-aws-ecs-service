resource "aws_cloudwatch_log_group" "service" {
  count = local.include_log_group == "yes" ? 1 : 0

  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.service_name}"
  retention_in_days = local.log_group_retention

  # TODO: rename Environment to DeploymentIdentifier as everywhere else
  tags = {
    Environment = var.deployment_identifier
    Component   = var.component
    Service     = var.service_name
  }
}
