
variable "project" {
  type    = "string"
}

variable "environment" {
  type    = "string"
}

variable "exa_db_password" {
  type    = "string"
}

variable "aws_s3_access_key" {
  type    = "string"
}

variable "aws_s3_secret_key" {
  type    = "string"
}

variable "release_label" {
  type    = "string"
}

variable "applications" {
  type    = "list"
}

variable "master_type" {
  type    = "string"
}

variable "master_count" {
  type    = "string"
}

variable "core_type" {
  type    = "string"
}

variable "core_count" {
  type    = "string"
}

variable "core_ebs_size" {
  default = "80"
}

variable "key_name" {
  type    = "string"
}

variable "key_pem_file" {
  type    = "string"
}

variable "core_vpc" {
  type = "string"
}

variable "public_subnet_2" {
  type = "string"
}

variable "exasol_emr_sg" {
  type = "string"
}

variable "waited_on" {
  type = "string"
}
