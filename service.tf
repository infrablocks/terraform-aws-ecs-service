resource "aws_ecs_service" "service_with_lb" {
  count = "${var.attach_to_load_balancer == "yes" ? "1" : "0"}"
  name = "${var.service_name}"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count = "${var.service_desired_count}"
  iam_role = "${var.ecs_cluster_service_role_arn}"

  deployment_maximum_percent = "${var.service_deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.service_deployment_minimum_healthy_percent}"

  scheduling_strategy = "${var.scheduling_strategy}"

  placement_constraints = "${var.placement_constraints}"

  load_balancer {
    elb_name = "${var.service_elb_name}"
    container_name = "${var.service_name}"
    container_port = "${var.service_port}"
  }
}

resource "aws_ecs_service" "service_without_lb" {
  count = "${var.attach_to_load_balancer == "yes" ? "0" : "1"}"
  name = "${var.service_name}"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count = "${var.service_desired_count}"

  deployment_maximum_percent = "${var.service_deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.service_deployment_minimum_healthy_percent}"

  scheduling_strategy = "${var.scheduling_strategy}"

  placement_constraints = "${var.placement_constraints}"
}
