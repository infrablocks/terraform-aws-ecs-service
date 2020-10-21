resource "aws_service_discovery_private_dns_namespace" "component" {
  name        = "${var.component}-${var.deployment_identifier}.${var.domain_name}"
  description = "sd-private-dns-ns-${var.component}-${var.deployment_identifier}"
  vpc         = module.base_network.vpc_id
}

resource "aws_service_discovery_service" "preexisting_service" {
  name = "preexisting"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.component.id

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
}
