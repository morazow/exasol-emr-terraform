# General Security Groups
#
# - Base Security Group, that can be used to restrict the access only from Jump / Bastion
# - Exasol Security Group, that will be attached to Exasol cluster nodes
# - EMR Security Group, that will be attached to ingress rules of EMR cluster

# Base Security Groups {{{
# A base security group that is attached to all nodes
# This can be adjusted only to allow traffic from bastion host if needed.
resource "aws_security_group" "base_sg" {
  name        = "base"
  description = "Allow basic inbound outbound traffic"
  vpc_id      = "${aws_vpc.core.id}"
}

# Add this to all instance that sent traffic to outside
resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.base_sg.id}"
}

resource "aws_security_group_rule" "ntp_egress" {
  type              = "egress"
  protocol          = "udp"
  from_port         = 123
  to_port           = 123
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.base_sg.id}"
}
# }}}

# Exasol and EMR Security Groups {{{
# A Security Group for Exasol cluster nodes
resource "aws_security_group" "exasol_sg" {
  name        = "exasol-sg"
  description = "Allow inbound traffic, use this group only for a exasol node"
  vpc_id      = "${aws_vpc.core.id}"
}

# A Security Group for EMR cluser nodes
resource "aws_security_group" "emr_sg" {
  name        = "emr-sg"
  description = "Allow inbound traffic, use this group only for a emr node"
  vpc_id      = "${aws_vpc.core.id}"
}

# Rules defining traffic between Exasol <-> EMR instances

# This will ensure that there is open traffic from exasol to emr cluster
resource "aws_security_group_rule" "ingress_exasol_emr_rule" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.exasol_sg.id}"
  security_group_id        = "${aws_security_group.emr_sg.id}"
}

# Similarly this will ensure that there is open traffic from emr to exasol cluster
resource "aws_security_group_rule" "ingress_emr_exasol_rule" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.emr_sg.id}"
  security_group_id        = "${aws_security_group.exasol_sg.id}"
}

# Rules defining traffic between Exasol <-> Internet (http / https)

resource "aws_security_group_rule" "ingress_exasol_http" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

resource "aws_security_group_rule" "ingress_exasol_https" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

# Rules defining traffic between Exasol <-> Internet (bucketfs)

resource "aws_security_group_rule" "ingress_exasol_bucketfs_http" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2580
  to_port           = 2580
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

resource "aws_security_group_rule" "ingress_exasol_bucketfs_https" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2581
  to_port           = 2581
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

resource "aws_security_group_rule" "ingress_exasol_jdbc" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8563
  to_port           = 8563
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

# Traffic within security group itself

resource "aws_security_group_rule" "ingress_exasol_self" {
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  self              = true
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

# Traffic outside
resource "aws_security_group_rule" "egress_exasol" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.exasol_sg.id}"
}

# }}}


# vim:foldmethod=marker:foldlevel=0
