
variable "project" {
  type    = "string"
}

variable "environment" {
  type    = "string"
}

variable "image_id" {
  type    = "string"
}

variable "license_file_path" {
  type    = "string"
}

variable "db_password" {
  type    = "string"
}

variable "db_node_count" {
  type    = "string"
}

variable "db_node_type" {
  type    = "string"
}

variable "db_replication_factor" {
  type    = "string"
}

variable "db_standby_node" {
  type    = "string"
}

variable "key_name" {
  type    = "string"
}

variable "core_vpc" {
  type = "string"
}

variable "base_sg" {
  type    = "string"
}

variable "public_subnet_1" {
  type = "string"
}

variable "exasol_sg" {
  type = "string"
}

variable "waited_on" {
  type = "string"
}
