resource aws_vpc kubernetes {
  cidr_block           = "10.20.16.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "kube-us-east-2-vpc"
  }
}

resource aws_internet_gateway igw {
  vpc_id = aws_vpc.kubernetes.id
}

resource aws_default_route_table drt {
  default_route_table_id = aws_vpc.kubernetes.default_route_table_id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    "kubernetes.io/cluster/testcluster" = "shared" //owned or shared
    use = "local"
  }
}

resource aws_subnet ohio_a {
  vpc_id                  = aws_vpc.kubernetes.id
  cidr_block              = "10.20.17.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/testcluster" = "shared" //owned or shared
  }

}

resource aws_subnet ohio_b {
  vpc_id                  = aws_vpc.kubernetes.id
  cidr_block              = "10.20.18.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/testcluster" = "shared" //owned or shared
  }
}

resource aws_subnet ohio_c {
  vpc_id                  = aws_vpc.kubernetes.id
  cidr_block              = "10.20.19.0/24"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/testcluster" = "shared" //owned or shared
  }
}

//resource aws_route_table_association rt_a {
//  subnet_id      = aws_subnet.ohio_a.id
//  route_table_id = aws_route_table.rt.id
//}
//
//resource aws_route_table_association rt_b {
//  subnet_id      = aws_subnet.ohio_b.id
//  route_table_id = aws_route_table.rt.id
//}
//
//resource aws_route_table_association rt_c {
//  subnet_id      = aws_subnet.ohio-c.id
//  route_table_id = aws_route_table.rt.id
//}

output vpc_id {
  value = aws_vpc.kubernetes.id
}

output route_table_id {
  value = aws_default_route_table.drt.id
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

//resource aws_vpc_endpoint ec2_endpoint {
//  vpc_id              = aws_vpc.kubernetes.id
//  service_name        = "com.amazonaws.us-east-2.ec2"
//  vpc_endpoint_type   = "Interface"
//  private_dns_enabled = true
//  subnet_ids          = [aws_subnet.ohio_a.id, aws_subnet.ohio_b.id, aws_subnet.ohio_c.id]
//  security_group_ids  = [aws_default_security_group.kube_vpc_default.id, aws_security_group.endpoint.id]
//}
//
//resource aws_vpc_endpoint elb_endpoint {
//  vpc_id              = aws_vpc.kubernetes.id
//  service_name        = "com.amazonaws.us-east-2.elasticloadbalancing"
//  vpc_endpoint_type   = "Interface"
//  private_dns_enabled = true
//  subnet_ids          = [aws_subnet.ohio_a.id, aws_subnet.ohio_b.id, aws_subnet.ohio_c.id]
//  security_group_ids  = [aws_default_security_group.kube_vpc_default.id, aws_security_group.endpoint.id]
//}

//
//resource aws_vpc_endpoint_subnet_association logs_route {
//  vpc_endpoint_id = aws_vpc_endpoint.logs_endpoint.id
//  subnet_id = aws_subnet.ohio_c.id
//}

resource aws_vpc_endpoint s3_endpoint {
  vpc_id       = aws_vpc.kubernetes.id
  service_name = "com.amazonaws.us-east-2.s3"
}

resource aws_vpc_endpoint_route_table_association s3_route {
  route_table_id  = aws_default_route_table.drt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}
