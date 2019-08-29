variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "profile" {
  type = string
}

variable "project" {
  type = string
}

variable "owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "exasol_database_name" {
  type = string
}

variable "exasol_cluster_name" {
  type = string
}

variable "exasol_image_name" {
  type = string
}

variable "exasol_sys_password" {
  type = string
}

variable "exasol_admin_password" {
  type = string
}

variable "exasol_management_server_type" {
  type = string
}

variable "exasol_datanode_count" {
  type = string
}

variable "exasol_datanode_type" {
  type = string
}

variable "exasol_standbynode_count" {
  type = string
}

variable "emr_release_label" {
  type = string
}

variable "emr_applications" {
  type    = list(string)
  default = ["Hadoop", "HCatalog", "Hive", "Spark"]
}

variable "emr_master_type" {
  type = string
}

variable "emr_master_count" {
  type = string
}

variable "emr_core_type" {
  type = string
}

variable "emr_core_count" {
  type = string
}

variable "aws_s3_access_key" {
  type = string
}

variable "aws_s3_secret_key" {
  type = string
}

variable "enable_datagen" {
  type = string
}

