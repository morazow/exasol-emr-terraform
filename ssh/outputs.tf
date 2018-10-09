
output "deployer_key_pair" {
  value = "${aws_key_pair.deployer.key_name}"
}

output "waited_on" {
  value = "${null_resource.waited_on.id}"
}
