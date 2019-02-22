
# Run data generation scripts
resource "null_resource" "run_data_generation" {
  count = "${var.enabled == "true" ? 1 : 0}"

  triggers {
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
      "hive -f $HOME/scripts/retail.sql"
    ]
  }

  # Run exasol import
  provisioner "remote-exec" {
    inline = [
      "$HOME/scripts/exa_hadoop_etl_import.sh"
    ]
  }
}
