# Create several folders in emr master node
resource "null_resource" "emr_master_provision_folders" {
  depends_on = ["aws_emr_cluster.emr_cluster"]

  connection {
    type        = "ssh"
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
}

# Render template files
resource "template_dir" "emr_templates" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/rendered"

  vars = {
    exa_password = "${var.exa_db_password}"
    aws_access_key = "${var.aws_s3_access_key}"
    aws_secret_key = "${var.aws_s3_secret_key}"
  }
}

# Trigger provision if anything changes in emr/templates folder
data "external" "templates_trigger" {
  program = ["${path.module}/utils/dirhash.sh"]
  query {
    directory = "${path.module}/templates"
  }
}

# Copy rendered template files
resource "null_resource" "emr_master_provision_templates" {
  depends_on = ["null_resource.emr_master_provision_folders"]

  triggers {
    md5 = "${data.external.templates_trigger.result["checksum"]}"
  }

  connection {
    type        = "ssh"
    user        = "hadoop"
    host        = "${aws_emr_cluster.emr_cluster.master_public_dns}"
    private_key = "${var.key_pem_file}"
    timeout     = "20m"
  }

  # Copy ETL Import Related Templates
  provisioner "file" {
    source      = "${template_dir.emr_templates.destination_dir}/"
    destination = "$HOME/scripts"
  }

  # Make bash files executable
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/scripts/*.sh"
    ]
  }
}

# Trigger provision if anything changes in emr/files folder
data "external" "files_trigger" {
  program = ["${path.module}/utils/dirhash.sh"]
  query {
    directory = "${path.module}/files"
  }
}

# Copy several provisioning files
resource "null_resource" "emr_master_provision_files" {
  depends_on = ["null_resource.emr_master_provision_folders"]

  triggers {
    md5 = "${data.external.files_trigger.result["checksum"]}"
  }

  connection {
    type        = "ssh"
    user        = "hadoop"
    host        = "${aws_emr_cluster.emr_cluster.master_public_dns}"
    private_key = "${var.key_pem_file}"
    timeout     = "20m"
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = "$HOME/scripts"
  }

  # Add authorized ssh public keys
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/scripts/bootstrap_user_keys.sh",
      "$HOME/scripts/bootstrap_user_keys.sh",
      "rm -rf $HOME/scripts/bootstrap_user_keys.sh"
    ]
  }

  # Install EXAPlus and other tools
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/scripts/bootstrap_tools.sh",
      "$HOME/scripts/bootstrap_tools.sh",
      "rm -rf $HOME/scripts/bootstrap_tools.sh"
    ]
  }
}
