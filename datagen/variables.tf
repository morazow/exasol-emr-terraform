
variable "enabled" {
  type    = "string"
}

variable "key_pem_file" {
  type    = "string"
}

variable "emr_master_public_dns" {
  type    = "string"
}

variable "emr_waited_on" {
  type    = "string"
}

variable "exasol_waited_on" {
  type    = "string"
}
