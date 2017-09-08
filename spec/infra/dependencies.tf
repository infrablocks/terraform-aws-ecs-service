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
  name = "test_role"

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

resource "aws_iam_role_policy" "task_role" {
  role = "${aws_iam_role.task_role.id}"
  policy = "${data.aws_iam_policy_document.task_role.json}"
}
