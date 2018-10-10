
resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content  = "${tls_private_key.ssh_private_key.private_key_pem}"
  filename = "generated/ssh/${var.project}-${var.environment}"
}

resource "local_file" "ssh_public_key" {
  content  = "${tls_private_key.ssh_private_key.public_key_openssh}"
  filename = "generated/ssh/${var.project}-${var.environment}.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project}-${var.environment}"
  public_key = "${tls_private_key.ssh_private_key.public_key_openssh}"
}

resource "null_resource" "waited_on" {
  depends_on = [
    "local_file.ssh_private_key",
    "local_file.ssh_public_key",
    "aws_key_pair.deployer"
  ]
}
