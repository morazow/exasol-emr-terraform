# AWS Networking and Security Group Setup
#
# - Core VPC
# - Core Internet Gateway
# - 2 Core Public Subnets

# Create a Core VPC {{{
# so that instances can live inside
resource "aws_vpc" "core" {
  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name        = "vpc-core-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
# }}}

# Create a Core Internet Gateway {{{
# to give subnets access to the outside world named internet
resource "aws_internet_gateway" "core_gw" {
  vpc_id = "${aws_vpc.core.id}"

  tags = {
    Name        = "gateway-core-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
# }}}

# Core Routing Table {{{
# Grants internet access to a VPC on its main route table
# This is used in public subnets
resource "aws_route_table" "core_rt_public" {
  vpc_id    = "${aws_vpc.core.id}"

  tags {
    Name        = "route-table-core-public-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "core_route" {
  route_table_id         = "${aws_route_table.core_rt_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.core_gw.id}"
  depends_on             = ["aws_internet_gateway.core_gw", "aws_route_table.core_rt_public"]
}
# }}}

# Public Subnets {{{
resource "aws_subnet" "core_subnet_public_1" {
  vpc_id                  = "${aws_vpc.core.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${lookup(var.av_zone_1, var.region)}"
  map_public_ip_on_launch = "true"

  tags {
    Name        = "subnet-public-1-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "core_subnet_public_2" {
  vpc_id                  = "${aws_vpc.core.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${lookup(var.av_zone_2, var.region)}"
  map_public_ip_on_launch = "true"

  tags {
    Name        = "subnet-public-2-${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
# }}}

# Routing Table - Public Subnet Association {{{
resource "aws_route_table_association" "core_subnet_public_1_assoc" {
  subnet_id      = "${aws_subnet.core_subnet_public_1.id}"
  route_table_id = "${aws_route_table.core_rt_public.id}"
}

resource "aws_route_table_association" "core_subnet_public_2_assoc" {
  subnet_id      = "${aws_subnet.core_subnet_public_2.id}"
  route_table_id = "${aws_route_table.core_rt_public.id}"
}
# }}}


# vim:foldmethod=marker:foldlevel=0
