
output "exasol_license_server_public_ip" {
  value = "${aws_cloudformation_stack.exasol_cluster.outputs["LicenseServerPublicIP"]}"
}
