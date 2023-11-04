resource "aws_cloudwatch_log_group" "service" {
  count = var.include_log_group ? 1 : 0

  name              = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.service_name}"
  retention_in_days = var.log_group_retention

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component            = var.component
    Service              = var.service_name
  }
}
