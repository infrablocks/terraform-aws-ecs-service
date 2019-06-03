module "base_network" {
  source  = "infrablocks/base-networking/aws"
  version = "0.6.0"

  region = "${var.region}"
  vpc_cidr = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  private_zone_id = "${var.private_zone_id}"

  infrastructure_events_bucket = "${var.infrastructure_events_bucket}"
}

module "ecs_cluster" {
  source  = "infrablocks/ecs-cluster/aws"
  version = "1.0.0"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  subnet_ids = "${module.base_network.private_subnet_ids}"
  allowed_cidrs = ["${var.private_network_cidr}"]

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
  source  = "infrablocks/ecs-load-balancer/aws"
  version = "1.0.0"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  subnet_ids = "${split(",", module.base_network.public_subnet_ids)}"

  service_name = "service"
  service_port = "${var.service_port}"

  service_certificate_arn = "${aws_iam_server_certificate.service.arn}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"

  allow_cidrs = "${split(",", var.elb_https_allow_cidrs)}"

  health_check_target = "${var.elb_health_check_target}"

  expose_to_public_internet = "yes"
  include_public_dns_record = "yes"
  store_access_logs = "no"
  access_logs_bucket = "not_used"
}

resource "aws_iam_server_certificate" "service" {
  name = "wildcard-certificate-${var.component}-${var.deployment_identifier}"
  private_key = "${file(var.service_certificate_private_key)}"
  certificate_body = "${file(var.service_certificate_body)}"
}

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "task_role" {
  name = "task-role-${var.deployment_identifier}"

  assume_role_policy = "${data.aws_iam_policy_document.task_assume_role.json}"
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role_policy" "task_role_policy" {
  role = "${aws_iam_role.task_role.id}"
  policy = "${data.aws_iam_policy_document.task_role.json}"
}
