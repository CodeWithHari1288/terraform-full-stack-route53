resource "aws_ec2_transit_gateway" "tgw" {
  description = "Demo Transit Gateway"

  tags = {
    Name = "demo-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.main.id
  subnet_ids         = [for s in aws_subnet.private : s.id]

  tags = {
    Name = "demo-tgw-attachment"
  }
}
