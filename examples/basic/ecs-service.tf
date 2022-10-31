module "ecs_service" {
  source = "./../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region

  service_name = "web-proxy"
  service_image = "nginx"
  service_command = ["nginx", "-g", "daemon off;"]
  service_port = 80

  attach_to_load_balancer = "yes"
  service_elb_name = module.ecs_load_balancer.name

  ecs_cluster_id = module.ecs_cluster.cluster_id
  ecs_cluster_service_role_arn = module.ecs_cluster.service_role_arn
}
