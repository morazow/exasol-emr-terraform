
resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster-${var.project}-${var.environment}"
  release_label = "emr-5.17.0"
  applications  = ["Spark", "Zeppelin", "Hive", "Hue"]

  ec2_attributes {
    key_name = "${var.key_name}"
    subnet_id = "${var.public_subnet_2}"
    instance_profile = "${aws_iam_instance_profile.emr_ec2_instance_profile.arn}"
    emr_managed_master_security_group = "${aws_security_group.master_sg.id}"
    additional_master_security_groups = "${var.exasol_emr_sg}"
    emr_managed_slave_security_group = "${aws_security_group.worker_sg.id}"
    additional_slave_security_groups = "${var.exasol_emr_sg}"
  }

  instance_group {
    instance_role = "MASTER"
    instance_type = "m4.xlarge"
    instance_count = "1"
  }

  instance_group {
    instance_role = "CORE"
    instance_type = "m4.2xlarge"
    instance_count = "3"
  }

  service_role = "${aws_iam_role.emr_service_role.arn}"

  depends_on = ["aws_security_group.master_sg","aws_security_group.worker_sg"]

  tags = {
    Name        = "emr-cluster-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
