resource aws_vpc workspaces {
  cidr_block           = "10.10.32.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "workspaces-us-east-1-vpc"
  }
}

resource aws_internet_gateway igw {
  vpc_id    = aws_vpc.workspaces.id
}

resource aws_default_route_table rt_public {
  default_route_table_id = aws_vpc.workspaces.default_route_table_id
  tags = {
    use = "private"
  }
}

//resource aws_route_table rt_public {
//  vpc_id   = aws_vpc.workspaces.id
//  route {
//    gateway_id = aws_internet_gateway.igw.id
//    cidr_block = "0.0.0.0/0"
//  }
//  tags = {
//    use = "open"
//  }
//}

resource aws_route_table rt_ws_public {
  vpc_id   = aws_vpc.workspaces.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    use = "public"
  }
}

resource aws_subnet nova_ws_public {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.47.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "public-net"
    sn_type = "public"
  }
}

resource aws_subnet nova_ws_a {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.33.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-a"
    sn_type = "private"
  }
}

resource aws_subnet nova_ws_b {
  vpc_id                  = aws_vpc.workspaces.id
  cidr_block              = "10.10.34.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-b"
    sn_type = "private"
  }
}
//
//resource aws_subnet nova_c {
//  vpc_id                  = aws_vpc.workspaces.id
//  cidr_block              = "10.20.51.0/24"
//  availability_zone       = "us-east-1c"
//  map_public_ip_on_launch = false
//  tags = {
//    Name    = "private-net-c"
//    sn_type = "private"
//  }
//}

resource aws_route_table_association rt_pub {
  subnet_id      = aws_subnet.nova_ws_public.id
  route_table_id = aws_route_table.rt_ws_public.id
}

//resource aws_route_table_association rt_a {
//  subnet_id      = aws_subnet.nova_a.id
//  route_table_id = aws_route_table.rt_private.id
//}
//
//resource aws_route_table_association rt_b {
//  subnet_id      = aws_subnet.nova_b.id
//  route_table_id = aws_route_table.rt_private.id
//}
//
//resource aws_route_table_association rt_c {
//  subnet_id      = aws_subnet.nova_c.id
//  route_table_id = aws_route_table.rt_private.id
//}

output vpc_id {
  value = aws_vpc.workspaces.id
}

output subnet_a_id {
  value = aws_subnet.nova_ws_a.id
}

output subnet_b_id {
  value = aws_subnet.nova_ws_b.id
}
//
//output subnet_c_id {
//  value = aws_subnet.nova_c.id
//}
