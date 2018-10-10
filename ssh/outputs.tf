
output "deployer_key_name" {
  value = "${aws_key_pair.deployer.key_name}"
}

output "deployer_key_pem" {
  value = "${tls_private_key.ssh_private_key.private_key_pem}"
}

output "waited_on" {
  value = "${null_resource.waited_on.id}"
}
