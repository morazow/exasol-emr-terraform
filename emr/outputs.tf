
output "emr_master_public_dns" {
  value = "${aws_emr_cluster.emr_cluster.master_public_dns}"
}

output "datagen_waited_on" {
  value = "${null_resource.datagen_waited_on.id}"
}
