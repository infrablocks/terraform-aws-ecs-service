resource "aws_elb" "service" {
  name = "elb-${var.service_name}-${var.component}-${var.deployment_identifier}"
  subnets = ["${split(",", var.elb_internal == "true" ? var.private_subnet_ids : var.public_subnet_ids)}"]

  internal = "${var.elb_internal}"

  security_groups = [
    "${aws_security_group.service_elb.id}"
  ]

  listener {
    instance_port = "${var.service_port}"
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.service_certificate_arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "${var.elb_health_check_target}"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 60

  tags {
    Name = "elb-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DevelopmentIdentifier = "${var.deployment_identifier}"
    Service = "${var.service_name}"
  }
}
