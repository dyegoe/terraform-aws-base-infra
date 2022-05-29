resource "aws_iam_role" "ec2_assume_role" {
  name                  = "${var.resource_name_prefix}-ec2-assume-role"
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [
      "ec2:DescribeInstances"
    ]

    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.this.account_id}:instance/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_assume_role" {
  name   = "${var.resource_name_prefix}-ec2-assume-role"
  path   = "/${var.resource_name_prefix}/"
  policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ec2_assume_role" {
  name = "${var.resource_name_prefix}-ec2-assume-role"
  role = aws_iam_role.ec2_assume_role.name
}
