resource aws_vpc workspaces {
  cidr_block           = "10.10.48.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "ws-2-us-east-1-vpc"
  }
}

resource aws_internet_gateway igw {
  vpc_id    = aws_vpc.workspaces.id
}


resource aws_default_route_table rt_public {
  default_route_table_id = aws_vpc.workspaces.default_route_table_id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    use = "public"
  }
}

resource aws_route_table rt_private {
  vpc_id   = aws_vpc.workspaces.id
  tags = {
    use = "local"
  }
}

resource aws_subnet nova_public {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.63.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "public-net"
    sn_type = "public"
  }
}

resource aws_subnet nova_a {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.49.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-a"
    sn_type = "private"
  }
}

resource aws_subnet nova_b {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.50.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-b"
    sn_type = "private"
  }
}

resource aws_route_table_association rt_a {
  subnet_id      = aws_subnet.nova_a.id
  route_table_id = aws_route_table.rt_private.id
}

resource aws_route_table_association rt_b {
  subnet_id      = aws_subnet.nova_b.id
  route_table_id = aws_route_table.rt_private.id
}

output vpc_id {
  value = aws_vpc.workspaces.id
}

output subnet_a_id {
  value = aws_subnet.nova_a.id
}

output subnet_b_id {
  value = aws_subnet.nova_b.id
}
