
output "exasol_management_server_ip" {
  value = module.exasol.management_server_ip
}

output "exasol_first_datanode_ip" {
  value = module.exasol.first_datanode_ip
}

output "emr_masternode_ip" {
  value = module.emr.master_public_dns
}

output "emr_masternode_private_ip" {
  value = module.emr.master_private_ip
}
