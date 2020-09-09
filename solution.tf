resource "aws_s3_bucket" "solution" {
  bucket        = "awsconfig-${lower(random_string.ec2.result)}"
  force_destroy = true
}

resource "aws_iam_role" "solution" {
  name               = "solution"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "solution" {
  name = "solution"
  role = aws_iam_role.solution.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.solution.arn}",
        "${aws_s3_bucket.solution.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "solution" {
  role       = aws_iam_role.solution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_delivery_channel" "solution" {
  name           = "solution"
  s3_bucket_name = aws_s3_bucket.solution.bucket
}

resource "aws_config_configuration_recorder" "solution" {
  name     = "solution"
  role_arn = aws_iam_role.solution.arn
}

resource "aws_config_configuration_recorder_status" "solution" {
  name       = aws_config_configuration_recorder.solution.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.solution]
}

resource "aws_config_config_rule" "restricted-ssh" {
  name        = "restricted-ssh"
  depends_on  = [aws_config_configuration_recorder.solution]
  description = "Checks whether the incoming SSH traffic for the security groups is accessible. The rule is COMPLIANT when IP addresses of the incoming SSH traffic in the security groups are restricted. This rule applies only to IPv4."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
}

resource "aws_config_config_rule" "ec2-instance-detailed-monitoring-enabled" {
  name        = "ec2-instance-detailed-monitoring-enabled"
  depends_on  = [aws_config_configuration_recorder.solution]
  description = "Checks whether detailed monitoring is enabled for EC2 instances. The rule is NON_COMPLIANT if detailed monitoring is not enabled."

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }
}
