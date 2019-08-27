
resource "aws_cloudformation_stack" "exasol_cluster" {
  name          = "exasol-stack-${var.project}-${var.environment}"
  capabilities  = ["CAPABILITY_IAM"]
  on_failure    = "DELETE"
  template_body = "${file("${path.module}/cloudformation_template_6.0.4-6.yml")}"

  parameters = {
    DBSystemName             = "exadb"
    DBPassword               = "${var.db_password}"
    ExasolPassword           = "${var.db_password}"
    DBSecurityGroup          = "${var.exasol_sg}"
    PublicSubnetId           = "${var.public_subnet_1}"
    DatabaseNodeInstanceType = "${var.db_node_type}"
    DBNodeCount              = "${var.db_node_count}"
    ReplicationFactor        = "${var.db_replication_factor}"
    StandbyNode              = "${var.db_standby_node}"
    KeyName                  = "${var.key_name}"
    ImageId                  = "${var.image_id}"
    License                  = "${file("${var.license_file_path}")}"
  }

  tags = {
    Name          = "exasol-cf-stack-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
    WaitedOn      = "${var.waited_on}"
  }
}

resource "null_resource" "exasol_wait" {
  depends_on = ["aws_cloudformation_stack.exasol_cluster"]

  triggers = {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = <<EOF
    python ${path.module}/utils/exa_xmlrpc.py \
      --license-server-address \
      ${aws_cloudformation_stack.exasol_cluster.outputs["LicenseServerPublicIP"]} \
      --username admin \
      --password ${var.db_password} \
      --buckets utils models
  EOF
  }
}

data "aws_instance" "exa_first_datanode" {
  instance_id = "${element(split(",", aws_cloudformation_stack.exasol_cluster.outputs["Datanodes"]), 0)}"
}

resource "null_resource" "exasol_upload_jars" {
  depends_on = ["null_resource.exasol_wait"]

  triggers = {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = <<EOF
    sleep 120

    URL="http://w:${var.db_password}@${data.aws_instance.exa_first_datanode.public_ip}:2580"
    BUCKET_URL="$URL/utils"

    for jar in `ls ${path.root}/artifacts/`
    do
      echo "Uploading jar = $jar to bucket utils"
      curl -X PUT -T "${path.root}/artifacts/$jar" "$BUCKET_URL/$jar"
    done
  EOF
  }
}

resource "null_resource" "datagen_waited_on" {
  depends_on = ["null_resource.exasol_upload_jars"]
}
