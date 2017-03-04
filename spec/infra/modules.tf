module "base_network" {
  source = "git@github.com:tobyclemson/terraform-aws-base-networking.git//src"

  vpc_cidr = "${var.vpc_cidr}"
  region = "${var.region}"
  availability_zones = "${var.availability_zones}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  bastion_ami = "${var.bastion_ami}"
  bastion_ssh_public_key_path = "${var.bastion_ssh_public_key_path}"
  bastion_ssh_allow_cidrs = "${var.bastion_ssh_allow_cidrs}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"
}

module "ecs_cluster" {
  source = "git@github.com:tobyclemson/terraform-aws-ecs-cluster.git//src"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"
  private_network_cidr = "${var.private_network_cidr}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  cluster_name = "${var.cluster_name}"
  cluster_instance_ssh_public_key_path = "${var.cluster_instance_ssh_public_key_path}"
  cluster_instance_type = "${var.cluster_instance_type}"

  cluster_minimum_size = "${var.cluster_minimum_size}"
  cluster_maximum_size = "${var.cluster_maximum_size}"
  cluster_desired_capacity = "${var.cluster_desired_capacity}"
}

module "ecs_load_balancer" {
  source = "git@github.com:tobyclemson/terraform-aws-ecs-load-balancer.git//src"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  public_subnet_ids = "${module.base_network.public_subnet_ids}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"

  service_name = "${var.service_name}"
  service_port = "${var.service_port}"

  service_certificate_arn = "${aws_iam_server_certificate.service.arn}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"

  elb_internal = "${var.elb_internal}"
  elb_health_check_target = "${var.elb_health_check_target}"
  elb_https_allow_cidrs = "${var.elb_https_allow_cidrs}"
}

module "ecs_service" {
  source = "../../src"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  public_subnet_ids = "${module.base_network.public_subnet_ids}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"

  service_name = "${var.service_name}"
  service_task_definition = "${var.service_task_definition}"
  service_image = "${var.service_image}"
  service_command = "${var.service_command}"
  service_port = "${var.service_port}"
  service_desired_count = "${var.service_desired_count}"
  service_elb_name = "${module.ecs_load_balancer.service_elb_name}"

  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"
  ecs_cluster_log_group = "${module.ecs_cluster.log_group}"
  ecs_cluster_service_role_arn = "${module.ecs_cluster.service_role_arn}"
}

