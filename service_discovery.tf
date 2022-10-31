resource "aws_service_discovery_service" "service" {
  count = (local.register_in_service_discovery == "yes" && local.service_discovery_create_registry == "yes") ? 1 : 0

  name = var.service_name

  dns_config {
    namespace_id = local.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = local.service_discovery_record_type
    }
  }
}
