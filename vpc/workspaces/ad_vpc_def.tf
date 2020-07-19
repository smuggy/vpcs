resource aws_vpc managed_ad {
  cidr_block           = "10.10.16.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "managed-ad-us-east-1-vpc"
  }
}

resource aws_subnet nova_mad_a {
  vpc_id                  = aws_vpc.managed_ad.id
  cidr_block              = "10.10.17.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-a"
    sn_type = "private"
  }
}

resource aws_subnet nova_mad_b {
  vpc_id                  = aws_vpc.managed_ad.id
  cidr_block              = "10.10.18.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name    = "private-net-b"
    sn_type = "private"
  }
}

resource aws_default_security_group managed_ad_security_group {
  vpc_id = aws_vpc.managed_ad.id

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 389
    to_port     = 389
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 53
    to_port     = 53
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
