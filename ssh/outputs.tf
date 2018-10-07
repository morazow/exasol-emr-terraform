
output "deployer_key_pair" {
  value = "${aws_key_pair.deployer.key_name}"
}
