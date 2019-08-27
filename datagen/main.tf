
# Run data generation: hive tables
# Hopefully, this should start once the emr cluster is ready,
# no need to wait for Exasol cluster to be up.
resource "null_resource" "data_gen_hive_tables" {
  count = "${var.enabled == "true" ? 1 : 0}"

  triggers = {
    file_retail = "${sha1(file("${path.root}/emr/files/retail.sql"))}"
  }

  connection {
    type        = "ssh"
    user        = "hadoop"
    host        = "${var.emr_master_public_dns}"
    private_key = "${var.key_pem_file}"
    timeout     = "20m"
  }

  # Run hive tables creation
  provisioner "remote-exec" {
    inline = [
      "echo Running hive tables: ${var.emr_waited_on}",
      "hive -f $HOME/scripts/retail.sql"
    ]
  }
}

# Run data generation: import hive tables into exasol
resource "null_resource" "data_gen_etl_import" {
  count = "${var.enabled == "true" ? 1 : 0}"

  triggers = {
    file_retail = "${sha1(file("${path.root}/emr/files/retail.sql"))}"
  }

  connection {
    type        = "ssh"
    user        = "hadoop"
    host        = "${var.emr_master_public_dns}"
    private_key = "${var.key_pem_file}"
    timeout     = "20m"
  }

  # Run exasol import
  provisioner "remote-exec" {
    inline = [
      "sleep 120",
      "echo Running etl import: ${var.exasol_waited_on}",
      "$HOME/scripts/exa_hadoop_etl_import.sh"
    ]
  }
}
