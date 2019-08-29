
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
  source                          = "../terraform-aws-exasol"
  project                         = var.project
  owner                           = var.owner
  environment                     = var.environment
  cluster_name                    = var.exasol_cluster_name
  database_name                   = var.exasol_database_name
  ami_image_name                  = var.exasol_image_name
  sys_user_password               = var.exasol_sys_password
  admin_user_password             = var.exasol_admin_password
  management_server_instance_type = var.exasol_management_server_type
  datanode_count                  = var.exasol_datanode_count
  datanode_instance_type          = var.exasol_datanode_type
  standbynode_count               = var.exasol_standbynode_count
  key_pair_name                   = module.ssh.deployer_key_name
  subnet_id                       = module.base.public_subnet_1
  security_group                  = module.base.exasol_sg
  waited_on                       = module.base.exasol_waited_on
}

resource "null_resource" "exasol_upload_artifacts" {
  depends_on = ["module.exasol.exasol_waited_on"]

  triggers = {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = <<EOF
    sleep 120

    URL="http://w:${var.exasol_admin_password}@${module.exasol.first_datanode_ip}:2580"
    BUCKET_URL="$URL/artifacts"

    for a in `ls ${path.root}/artifacts/`
    do
      echo "Uploading artifact: $a"
      curl -X PUT -T "${path.root}/artifacts/$a" "$BUCKET_URL/$a"
    done
  EOF
  }
}

module "emr" {
  source                = "./emr"
  project               = var.project
  environment           = var.environment
  exa_db_password       = var.exasol_sys_password
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
  emr_master_public_dns = module.emr.master_public_dns
  emr_waited_on         = module.emr.datagen_waited_on
  exasol_waited_on      = "${null_resource.exasol_upload_artifacts.id}"
}

