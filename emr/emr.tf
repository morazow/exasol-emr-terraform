# AWS EMR Cluster
resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster-${var.project}-${var.environment}"
  release_label = "${var.release_label}"
  applications  = "${var.applications}"

  ec2_attributes {
    key_name = "${var.key_name}"
    subnet_id = "${var.public_subnet_2}"
    instance_profile = "${aws_iam_instance_profile.emr_ec2_instance_profile.arn}"
    emr_managed_master_security_group = "${aws_security_group.master_sg.id}"
    additional_master_security_groups = "${var.exasol_emr_sg}"
    emr_managed_slave_security_group = "${aws_security_group.worker_sg.id}"
    additional_slave_security_groups = "${var.exasol_emr_sg}"
  }

  master_instance_group {
    instance_type = "${var.master_type}"
    instance_count = "${var.master_count}"
  }

  core_instance_group {
    instance_type = "${var.core_type}"
    instance_count = "${var.core_count}"
    ebs_config {
      size = "${var.core_ebs_size}"
      type = "gp2"
      volumes_per_instance = 1
    }
  }

  service_role = "${aws_iam_role.emr_service_role.arn}"

  tags = {
    Name          = "emr-cluster-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
    WaitedOn      = "${var.waited_on}"
  }
}
