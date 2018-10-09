
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "ssh" {
  source      = "./ssh"
  project     = "${var.project}"
  environment = "${var.environment}"
}

module "base" {
  source      = "./base"
  region      = "${var.region}"
  project     = "${var.project}"
  environment = "${var.environment}"
  waited_on   = "${module.ssh.waited_on}"
}

module "exasol" {
  source          = "./exasol"
  project         = "${var.project}"
  environment     = "${var.environment}"
  db_password     = "${var.exa_db_password}"
  db_node_count   = "${var.exa_db_node_count}"
  db_replication  = "${var.exa_db_replication_factor}"
  db_standby_node = "${var.exa_db_standby_node}"
  key_name        = "${module.ssh.deployer_key_pair}"
  core_vpc        = "${module.base.core_vpc}"
  base_sg         = "${module.base.base_sg}"
  public_subnet_1 = "${module.base.public_subnet_1}"
  exasol_sg       = "${module.base.exasol_sg}"
  waited_on       = "${module.base.exasol_waited_on}"
}

module "emr" {
  source          = "./emr"
  project         = "${var.project}"
  environment     = "${var.environment}"
  exa_db_password = "${var.exa_db_password}"
  release_label   = "${var.emr_release_label}"
  master_type     = "${var.emr_master_type}"
  master_count    = "${var.emr_master_count}"
  core_type       = "${var.emr_core_type}"
  core_count      = "${var.emr_core_count}"
  key_name        = "${module.ssh.deployer_key_pair}"
  core_vpc        = "${module.base.core_vpc}"
  public_subnet_2 = "${module.base.public_subnet_2}"
  exasol_emr_sg   = "${module.base.emr_sg}"
  waited_on       = "${module.base.emr_waited_on}"
}
