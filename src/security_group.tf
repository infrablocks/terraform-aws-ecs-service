resource "aws_security_group" "service_elb" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"
  description = "${var.component}-elb"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${split(",", coalesce(var.elb_https_allow_cidrs, var.private_network_cidr))}"
    ]
  }

  egress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${var.private_network_cidr}"
    ]
  }
}

