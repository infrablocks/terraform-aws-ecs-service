resource "aws_cloudwatch_log_group" "service" {
  count = var.include_log_group == "yes" ? 1 : 0

  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.service_name}"

  tags = {
    Environment = var.deployment_identifier
    Component   = var.component
    Service     = var.service_name
  }
}
