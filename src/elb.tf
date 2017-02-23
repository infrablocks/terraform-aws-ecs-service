resource "aws_iam_server_certificate" "service" {
  name = "wildcard-certificate-${var.component}-${var.deployment_identifier}"
  private_key = "${file(var.service_certificate_private_key)}"
  certificate_body = "${file(var.service_certificate_body)}"
}

resource "aws_elb" "service" {
  name = "elb-${var.service_name}-${var.component}-${var.deployment_identifier}"
  subnets = ["${split(",", var.private_subnet_ids)}"]


  listener {
    instance_port = "${var.service_port}"
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.service.arn}"
  }

}
