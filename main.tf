
provider "aws" {
  region      = var.region
  profile     = var.profile
}

module "ssh" {
  source      = "./ssh"
  project     = var.project
  environment = var.environment
}

module "base" {
  source      = "./base"
  region      = var.region
  project     = var.project
  environment = var.environment
  waited_on   = module.ssh.waited_on
}

module "exasol" {
  source                = "./exasol"
  project               = var.project
  environment           = var.environment
  image_id              = var.exa_image_id
  license_file_path     = var.exa_license_file_path
  db_password           = var.exa_db_password
  db_node_count         = var.exa_db_node_count
  db_node_type          = var.exa_db_node_type
  db_replication_factor = var.exa_db_replication_factor
  db_standby_node       = var.exa_db_standby_node
  key_name              = module.ssh.deployer_key_name
  core_vpc              = module.base.core_vpc
  base_sg               = module.base.base_sg
  public_subnet_1       = module.base.public_subnet_1
  exasol_sg             = module.base.exasol_sg
  waited_on             = module.base.exasol_waited_on
}

module "emr" {
  source                = "./emr"
  project               = var.project
  environment           = var.environment
  exa_db_password       = var.exa_db_password
  release_label         = var.emr_release_label
  applications          = var.emr_applications
  master_type           = var.emr_master_type
  master_count          = var.emr_master_count
  core_type             = var.emr_core_type
  core_count            = var.emr_core_count
  aws_s3_access_key     = var.aws_s3_access_key
  aws_s3_secret_key     = var.aws_s3_secret_key
  key_name              = module.ssh.deployer_key_name
  key_pem_file          = module.ssh.deployer_key_pem
  core_vpc              = module.base.core_vpc
  public_subnet_2       = module.base.public_subnet_2
  exasol_emr_sg         = module.base.emr_sg
  waited_on             = module.base.emr_waited_on
}

module "datagen" {
  source                = "./datagen"
  enabled               = var.enable_datagen
  key_pem_file          = module.ssh.deployer_key_pem
  emr_master_public_dns = module.emr.emr_master_public_dns
  emr_waited_on         = module.emr.datagen_waited_on
  exasol_waited_on      = module.exasol.datagen_waited_on
}

