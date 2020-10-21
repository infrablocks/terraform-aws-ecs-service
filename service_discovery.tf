resource "aws_service_discovery_service" "service" {
  count = var.register_in_service_discovery == "yes" ? 1 : 0

  name = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = var.service_discovery_record_type
    }
  }
}
