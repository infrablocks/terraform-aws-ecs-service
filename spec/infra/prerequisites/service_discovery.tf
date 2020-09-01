resource "aws_service_discovery_private_dns_namespace" "component" {
  name        = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
  description = "sd-private-dns-ns-${var.component}-${var.deployment_identifier}"
  vpc         = module.base_network.vpc_id
}
