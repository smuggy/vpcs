resource aws_vpc utility {
  cidr_block           = "10.20.32.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "utility-us-east-2-vpc"
  }
}

resource aws_internet_gateway igw {
  vpc_id = aws_vpc.utility.id
}

resource aws_default_route_table drt {
  default_route_table_id = aws_vpc.utility.default_route_table_id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    use = "local"
  }
}

resource aws_subnet ohio_a {
  vpc_id                  = aws_vpc.utility.id
  cidr_block              = "10.20.33.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource aws_subnet ohio_b {
  vpc_id                  = aws_vpc.utility.id
  cidr_block              = "10.20.34.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}

resource aws_subnet ohio_c {
  vpc_id                  = aws_vpc.utility.id
  cidr_block              = "10.20.35.0/24"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true
}

output route_table_id {
  value = aws_default_route_table.drt.id
}

output vpc_id {
  value = aws_vpc.utility.id
}

output subnet_a_id {
  value = aws_subnet.ohio_a.id
}

output subnet_b_id {
  value = aws_subnet.ohio_b.id
}

output subnet_c_id {
  value = aws_subnet.ohio_c.id
}
