resource "aws_route53_record" "service_public" {
  zone_id = "${var.public_zone_id}"
  name = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.service.dns_name}"
    zone_id = "${aws_elb.service.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "service_private" {
  zone_id = "${var.private_zone_id}"
  name = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.service.dns_name}"
    zone_id = "${aws_elb.service.zone_id}"
    evaluate_target_health = false
  }
}
