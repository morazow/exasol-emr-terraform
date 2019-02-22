
variable "enabled" {
  type    = "string"
}

variable "key_pem_file" {
  type    = "string"
}

variable "emr_master_public_dns" {
  type    = "string"
}

variable "depends_on" {
  type    = "list"
}
