module "base_network" {
  source  = "infrablocks/base-networking/aws"
  version = "4.1.0-rc.5"

  region = var.region
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones

  component = var.component
  deployment_identifier = var.deployment_identifier

  private_zone_id = var.private_zone_id

  include_nat_gateways = "no"
}

module "acm_certificate" {
  source = "infrablocks/acm-certificate/aws"
  version = "1.2.0-rc.1"

  domain_name = "*.${var.domain_name}"
  domain_zone_id = var.public_zone_id
  subject_alternative_name_zone_id = var.public_zone_id

  providers = {
    aws.certificate = aws
    aws.domain_validation = aws
    aws.san_validation = aws
  }
}

module "ecs_cluster" {
  source  = "infrablocks/ecs-cluster/aws"
  version = "4.3.0-rc.3"

  region = var.region
  vpc_id = module.base_network.vpc_id
  subnet_ids = module.base_network.private_subnet_ids
  allowed_cidrs = [var.private_network_cidr]

  component = var.component
  deployment_identifier = var.deployment_identifier

  cluster_name = var.cluster_name
  cluster_instance_ssh_public_key_path = var.cluster_instance_ssh_public_key_path
  cluster_instance_type = var.cluster_instance_type

  cluster_minimum_size = var.cluster_minimum_size
  cluster_maximum_size = var.cluster_maximum_size
  cluster_desired_capacity = var.cluster_desired_capacity
}

module "ecs_load_balancer" {
  source  = "infrablocks/ecs-load-balancer/aws"
  version = "3.1.0-rc.7"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = module.base_network.vpc_id
  subnet_ids = module.base_network.public_subnet_ids

  service_name = "web-proxy"
  service_port = 80

  service_certificate_arn = module.acm_certificate.certificate_arn

  domain_name = var.domain_name
  public_zone_id = var.public_zone_id
  private_zone_id = var.private_zone_id

  allow_cidrs = ["0.0.0.0/0"]

  expose_to_public_internet = "yes"
  include_public_dns_record = "yes"
}
