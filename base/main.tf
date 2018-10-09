# Resources dependent from other modules if they are build independently

resource "null_resource" "exasol_waited_on" {
  depends_on = [
    "aws_route.core_route",
    "aws_subnet.core_subnet_public_1",
    "aws_route_table_association.core_subnet_public_1_assoc",
    "null_resource.exasol_sg_waited_on"
  ]
}

resource "null_resource" "emr_waited_on" {
  depends_on = [
    "aws_route.core_route",
    "aws_subnet.core_subnet_public_2",
    "aws_route_table_association.core_subnet_public_2_assoc"
  ]
}
