output "task_definition_arn" {
  description = "The ARN of the created ECS task definition."
  value = "${aws_ecs_task_definition.service.arn}"
}

output "log_group" {
  description = "The name of the log group capturing all task output."
  value = "${aws_cloudwatch_log_group.service.name}"
}