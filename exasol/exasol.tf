
resource "aws_cloudformation_stack" "exasol_cluster" {
  name          = "exasol-stack-${var.project}-${var.environment}"
  capabilities  = ["CAPABILITY_IAM"]
  on_failure    = "DELETE"
  template_body = "${file("${path.module}/exasol_cf.yml")}"

  parameters {
    DBSystemName      = "exadb"
    DBPassword        = "${var.db_password}"
    ExasolPassword    = "${var.db_password}"
    DBSecurityGroup   = "${var.exasol_sg}"
    PublicSubnetId    = "${var.public_subnet_1}"
    DBNodeCount       = "${var.db_node_count}"
    ReplicationFactor = "${var.db_replication}"
    StandbyNode       = "${var.db_standby_node}"
    KeyName           = "${var.key_name}"
    ImageId           = "EXASOL-6.0.6-4-BYOL"
    License           = "${file("${path.module}/byol_license.xml")}"
  }

  tags = {
    Name        = "exasol-cf-stack-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    WaitedOn    = "${var.waited_on}"
  }
}
