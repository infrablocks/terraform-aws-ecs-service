
resource "aws_lb" "application_load_balancer" {
  internal = false

  load_balancer_type = "application"

  security_groups = [
    "${module.ecs_load_balancer.security_group_id}",
  ]

  subnets = "${split(",", module.base_network.public_subnet_ids)}"

  idle_timeout = 60

  tags = {
    Name = "alb-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}

resource "aws_lb_target_group" "target_group" {
  port = "${var.service_port}"
  protocol = "HTTP"
  vpc_id = "${module.base_network.vpc_id}"

  health_check {
    path = "${var.alb_health_check_path}"
    port = "${var.service_port}"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
  }

  tags = {
    Name = "target-group-web-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }

  depends_on = [
    "aws_lb.application_load_balancer",
  ]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.application_load_balancer.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn = "${aws_iam_server_certificate.service.arn}"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}
