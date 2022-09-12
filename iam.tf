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
  tags                  = { "Name" = "${var.resource_name_prefix}-ec2-assume-role" }
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
  tags   = { "Name" = "${var.resource_name_prefix}-ec2-assume-role" }
}

resource "aws_iam_role_policy_attachment" "ec2_assume_role" {
  role       = aws_iam_role.ec2_assume_role.name
  policy_arn = aws_iam_policy.ec2_assume_role.arn
}

data "aws_iam_policy_document" "certbot" {
  statement {
    actions = [
      "route53:GetChange",
      "route53:ListHostedZones",
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "certbot" {
  name   = "${var.resource_name_prefix}-certbot"
  path   = "/${var.resource_name_prefix}/"
  policy = data.aws_iam_policy_document.certbot.json
  tags   = { "Name" = "${var.resource_name_prefix}-certbot" }
}

resource "aws_iam_role_policy_attachment" "certbot" {
  role       = aws_iam_role.ec2_assume_role.name
  policy_arn = aws_iam_policy.certbot.arn
}

resource "aws_iam_instance_profile" "ec2_assume_role" {
  name = "${var.resource_name_prefix}-ec2-assume-role"
  role = aws_iam_role.ec2_assume_role.name
  tags = { "Name" = "${var.resource_name_prefix}-ec2-assume-role" }
}
