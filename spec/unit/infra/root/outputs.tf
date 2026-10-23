output "task_definition_arn" {
  value = module.ecs_service.task_definition_arn
}

output "service_name" {
  value = module.ecs_service.service_name
}

output "autoscaling_target_resource_id" {
  value = module.ecs_service.autoscaling_target_resource_id
}
