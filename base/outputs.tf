
output "core_vpc" {
  value = "${aws_vpc.core.id}"
}

output "base_sg" {
  value = "${aws_security_group.base_sg.id}"
}

output "public_subnet_1" {
  value = "${aws_subnet.core_subnet_public_1.id}"
}

output "public_subnet_2" {
  value = "${aws_subnet.core_subnet_public_2.id}"
}

output "exasol_sg" {
  value = "${aws_security_group.exasol_sg.id}"
}

output "emr_sg" {
  value = "${aws_security_group.emr_sg.id}"
}
