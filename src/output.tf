output "task_definition_arn" {
  value = "${aws_ecs_task_definition.service.arn}"
}

output "log_group" {
  value = "${aws_cloudwatch_log_group.service.name}"
}