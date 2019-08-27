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

variable "environment" {
  type = string
}

variable "exa_image_id" {
  type = string
}

variable "exa_license_file_path" {
  type = string
}

variable "exa_db_password" {
  type = string
}

variable "exa_db_node_count" {
  type = string
}

variable "exa_db_node_type" {
  type = string
}

variable "exa_db_replication_factor" {
  type = string
}

variable "exa_db_standby_node" {
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

