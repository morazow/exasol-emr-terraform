
resource "aws_security_group" "master_sg" {
  name = "emr-master-sg-${var.project}-${var.environment}"
  description = "Allow inbound traffic for EMR Master node"
  vpc_id = "${var.core_vpc}"

  # Avoid circular dependencies which may stop the destroy of a cluster
  revoke_rules_on_delete = true

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "emr-master-sg-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "emr-worker-sg-${var.project}-${var.environment}"
  description = "Allow inbound outbound traffic for EMR Worker (Slave) nodes"
  vpc_id      = "${var.core_vpc}"

  # Avoid circular dependencies which may stop the destroy of a cluster
  revoke_rules_on_delete = true

  # Allow communication between nodes, adds itself as a source
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "emr-worker-sg-${var.project}-${var.environment}"
    Project       = "${var.project}"
    "exa:project" = "${var.project}"
    Environment   = "${var.environment}"
  }
}
