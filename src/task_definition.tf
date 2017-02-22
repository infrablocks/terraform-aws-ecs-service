data "template_file" "service" {
  template = "${coalesce(var.service_task_definition, file("${path.module}/task-definitions/service.json.tpl"))}"

  vars {
    name = "${var.service_name}"
    image = "${var.service_image}"
    command = "${jsonencode(var.service_command)}"
    port = "${var.service_port}"
    region = "${var.region}"
    log_group = "${var.ecs_cluster_log_group}"
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.service_name}-${var.component}-${var.deployment_identifier}"
  container_definitions = "${data.template_file.service.rendered}"
}

