
data "template_file" "emr_configurations" {
  template = "${file("${path.module}/templates/configurations.json.tpl")}"

  vars = {
    spark_exasol_connector_jar = "/home/hadoop/jars/spark-exasol-connector-assembly-0.1.0.jar"
  }
}

resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster-${var.project}-${var.environment}"
  release_label = "${var.release_label}"
  applications  = ["Hadoop", "HCatalog", "Hive", "Hue", "Spark", "Zeppelin"]

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
    instance_type = "${var.master_type}"
    instance_count = "${var.master_count}"
  }

  instance_group {
    instance_role = "CORE"
    instance_type = "${var.core_type}"
    instance_count = "${var.core_count}"
    ebs_config {
      size = "${var.core_ebs_size}"
      type = "gp2"
      volumes_per_instance = 1
    }
  }

  service_role = "${aws_iam_role.emr_service_role.arn}"

  configurations = "${data.template_file.emr_configurations.rendered}"

  tags = {
    Name        = "emr-cluster-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    WaitedOn    = "${var.waited_on}"
  }
}

data "template_file" "exa_etl_import_template" {
  template = "${file("${path.module}/templates/exa_etl_import.sh.tpl")}"

  vars = {
    exa_password = "${var.exa_db_password}"
  }
}

data "template_file" "exa_s3etl_import_template" {
  template = "${file("${path.module}/templates/exa_s3etl_import.sh.tpl")}"

  vars = {
    exa_password   = "${var.exa_db_password}"
    aws_access_key = "${var.aws_s3_access_key}"
    aws_secret_key = "${var.aws_s3_secret_key}"
  }
}

resource "null_resource" "emr_master_configs" {

  # Should we run this resource on second `terraform apply`?
  triggers = {
    # Yes, if template file changes
    template_etl   = "${data.template_file.exa_etl_import_template.rendered}"
    template_s3etl = "${data.template_file.exa_s3etl_import_template.rendered}"
    # Yes, if one these files change
    file_retail    = "${sha1(file("${path.module}/files/retail.sql"))}"
    file_userkeys  = "${sha1(file("${path.module}/files/bootstrap_user_keys.sh"))}"
  }

  connection {
    type = "ssh"
    user        = "hadoop"
    host        = "${aws_emr_cluster.emr_cluster.master_public_dns}"
    private_key = "${var.key_pem_file}"
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/scripts",
      "mkdir -p $HOME/exaplus",
      "mkdir -p $HOME/jars"
    ]
  }

  # Copy ETL Import Related Templates & Files

  provisioner "file" {
    content     = "${data.template_file.exa_etl_import_template.rendered}"
    destination = "$HOME/scripts/exa_etl_import.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.exa_s3etl_import_template.rendered}"
    destination = "$HOME/scripts/exa_s3etl_import.sh"
  }

  provisioner "file" {
    source      = "${path.module}/files/retail.sql"
    destination = "$HOME/scripts/retail.sql"
  }

  provisioner "file" {
    source      = "${path.module}/files/udf_debug.py"
    destination = "$HOME/scripts/udf_debug.py"
  }

  provisioner "file" {
    source      = "${path.module}/files/bootstrap_user_keys.sh"
    destination = "$HOME/scripts/bootstrap_user_keys.sh"
  }

  # Copy jars/ folder contents into remote $HOME/jars/ folder

  provisioner "file" {
    source      = "${path.module}/jars/"
    destination = "$HOME/jars"
  }

  # Add authorized ssh public keys

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/scripts/bootstrap_user_keys.sh",
      "$HOME/scripts/bootstrap_user_keys.sh",
      "rm -rf $HOME/scripts/bootstrap_user_keys.sh"
    ]
  }

  # Install EXAPlus and download parquet-tools jar

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y tmux curl wget git htop",
      "wget https://www.exasol.com/support/secure/attachment/63966/EXAplus-6.0.10.tar.gz",
      "tar zxv --exclude='doc' -f EXAplus-6.0.10.tar.gz",
      "mv EXAplus-6.0.10/exaplus EXAplus-6.0.10/*.jar exaplus",
      "rm -rf EXAplus-6.0.10*",
      "wget http://central.maven.org/maven2/org/apache/parquet/parquet-tools/1.8.1/parquet-tools-1.8.1.jar -P $HOME/jars/"
    ]
  }

  # Make exa_*_import.sh executable

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/scripts/exa_etl_import.sh",
      "chmod +x $HOME/scripts/exa_s3etl_import.sh"
    ]
  }

}
