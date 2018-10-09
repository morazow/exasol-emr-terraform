
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
  key_name        = "${module.ssh.deployer_key_pair}"
  core_vpc        = "${module.base.core_vpc}"
  public_subnet_2 = "${module.base.public_subnet_2}"
  exasol_emr_sg   = "${module.base.emr_sg}"
  waited_on       = "${module.base.emr_waited_on}"
}
