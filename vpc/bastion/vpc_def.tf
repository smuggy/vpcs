data aws_region current {}

locals {
  region = data.aws_region.current.name
}

resource aws_vpc bt_vpc {
  cidr_block           = "10.20.64.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "bastion-${local.region}-vpc"
  }
}

resource aws_internet_gateway igw {
  vpc_id    = aws_vpc.bt_vpc.id
}

resource aws_route_table rt_public {
  vpc_id   = aws_vpc.bt_vpc.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    use = "open"
  }
}

resource aws_route_table rt_private {
  vpc_id   = aws_vpc.bt_vpc.id
  tags = {
    use = "local"
  }
}

resource aws_subnet bt_public {
  vpc_id                  = aws_vpc.bt_vpc.id
  cidr_block              = "10.20.79.0/24"
  availability_zone       = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "public-net"
    sg_type = "public"
  }
}

resource aws_subnet bt_private {
  vpc_id                  = aws_vpc.bt_vpc.id
  cidr_block              = "10.20.65.0/24"
  availability_zone       = "${local.region}b"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net"
    sg_type = "private"
  }
}

resource aws_route_table_association rt_pub {
  subnet_id      = aws_subnet.bt_public.id
  route_table_id = aws_route_table.rt_public.id
}

resource aws_route_table_association rt_b {
  subnet_id      = aws_subnet.bt_private.id
  route_table_id = aws_route_table.rt_private.id
}

output vpc_id {
  value = aws_vpc.bt_vpc.id
}

output subnet_a_id {
  value = aws_subnet.bt_public.id
}

output subnet_b_id {
  value = aws_subnet.bt_private.id
}

resource aws_vpc_endpoint s3 {
  vpc_id       = aws_vpc.bt_vpc.id
  service_name = "com.amazonaws.${local.region}.s3"
}

resource aws_vpc_endpoint_route_table_association s3 {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.rt_public.id
}

resource aws_vpc_endpoint_route_table_association private_s3 {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.rt_private.id
}
//
//resource aws_vpc_endpoint ec2 {
//  vpc_id       = aws_vpc.bt_vpc.id
//  service_name = "com.amazonaws.${local.region}.ec2"
//  vpc_endpoint_type   = "Interface"
//  private_dns_enabled = true
//  subnet_ids = [aws_subnet.bt_public.id, aws_subnet.bt_private.id]
//  security_group_ids = [aws_default_security_group.bt_security_group.id]
//}
