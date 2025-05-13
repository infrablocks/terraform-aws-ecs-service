module "ecs_service" {
  source = "./../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  service_task_container_definitions = file("${path.module}/container-definitions/service.json.tpl")

  region = var.region

  subnet_ids = module.base_network.private_subnet_ids

  service_name = "web-proxy"
  service_image = "nginx"
  service_command = ["nginx", "-g", "daemon off;"]
  service_port = 80

  use_fargate = true
  service_task_cpu = "256"
  service_task_memory = "512"
  service_task_operating_system_family = "LINUX"

  attach_to_load_balancer = false
  # service_elb_name = module.ecs_load_balancer.name

  ecs_cluster_id = module.ecs_cluster.cluster_id
  ecs_cluster_service_role_arn = module.ecs_cluster.service_role_arn
}
