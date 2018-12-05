# AWS EMR Service and Profile Roles Setup
#
# - EMR Service Role
# - EMR EC2 Instance Profile Role

# Create EMR Service Role {{{
# This role defines what is allowed to do within a EMR environment
resource "aws_iam_role" "emr_service_role" {
  name = "emr-service-role-${var.project}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name          = "emr-service-role-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
  }
}

# Attach default EMR service policy
resource "aws_iam_role_policy_attachment" "emr_service_role_policy" {
  role = "${aws_iam_role.emr_service_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}
# }}}

# Create EMR EC2 Instance Profile Role {{{
# This role defines what is allowed to do within a EC2 environment
resource "aws_iam_role" "emr_profile_role" {
  name = "emr-profile-role-${var.project}-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name          = "emr-profile-role-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
  }
}

# Attach default EC2 profile policy
resource "aws_iam_role_policy_attachment" "emr_profile_role_policy" {
  role = "${aws_iam_role.emr_profile_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# An EMR EC2 instance profile used to attacht to the EMR EC2 instances
resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "emr-ec2-profile-${var.project}-${var.environment}"
  role = "${aws_iam_role.emr_profile_role.name}"
}
# }}}


# vim:foldmethod=marker:foldlevel=0
