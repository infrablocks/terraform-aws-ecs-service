output "task_definition_arn" {
  value = "${module.ecs_service.task_definition_arn}"
}
