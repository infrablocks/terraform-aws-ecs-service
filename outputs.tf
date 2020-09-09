output "task_definition_arn" {
  description = "The ARN of the created ECS task definition."
  value = aws_ecs_task_definition.service.arn
}

output "log_group" {
  description = "The name of the log group capturing all task output."
  value = var.include_log_group == "yes" ? aws_cloudwatch_log_group.service[0].name : ""
}

output "security_group_id" {
  description = "The ID of the default security group associated with the network interfaces of the ECS tasks."
  value = (var.associate_default_security_group == "yes" && var.service_task_network_mode == "awsvpc") ? aws_security_group.task.0.id : ""
}
