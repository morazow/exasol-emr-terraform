
output "exasol_license_server_public_ip" {
  value = "${aws_cloudformation_stack.exasol_cluster.outputs["LicenseServerPublicIP"]}"
}

output "exasol_first_datanode_ip" {
  value = "${element(split(",", aws_cloudformation_stack.exasol_cluster.outputs["Datanodes"]), 0)}"
}

output "datagen_waited_on" {
  value = "${null_resource.datagen_waited_on.id}"
}
