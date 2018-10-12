
resource "aws_cloudformation_stack" "exasol_cluster" {
  name          = "exasol-stack-${var.project}-${var.environment}"
  capabilities  = ["CAPABILITY_IAM"]
  on_failure    = "DELETE"
  template_body = "${file("${path.module}/exasol_cloudformation.yml")}"

  parameters {
    DBSystemName      = "exadb"
    DBPassword        = "${var.db_password}"
    ExasolPassword    = "${var.db_password}"
    DBSecurityGroup   = "${var.exasol_sg}"
    PublicSubnetId    = "${var.public_subnet_1}"
    DBNodeCount       = "${var.db_node_count}"
    ReplicationFactor = "${var.db_replication_factor}"
    StandbyNode       = "${var.db_standby_node}"
    KeyName           = "${var.key_name}"
    ImageId           = "${var.image_id}"
    License           = "${file("${var.license_file_path}")}"
  }

  tags = {
    Name        = "exasol-cf-stack-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    WaitedOn    = "${var.waited_on}"
  }
}
