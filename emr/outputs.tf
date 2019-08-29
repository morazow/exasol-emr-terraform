
output "master_public_dns" {
  value = "${aws_emr_cluster.emr_cluster.master_public_dns}"
}

output "master_private_ip" {
  value = "${data.aws_instance.emr_master.private_ip}"
}

output "datagen_waited_on" {
  value = "${null_resource.datagen_waited_on.id}"
}
