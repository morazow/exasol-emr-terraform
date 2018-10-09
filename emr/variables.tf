
variable "project" {
  type    = "string"
}

variable "environment" {
  type    = "string"
}

variable "exa_db_password" {
  type    = "string"
}

variable "release_label" {
  type    = "string"
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

variable "key_name" {
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
