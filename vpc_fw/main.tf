resource aws_vpc vpc {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  tags                 = {
    Name = local.vpc_name
  }
}

locals {
  vpc_name       = "test-fw-vpc"
  region         = "us-east-2"
  cidr_block     = "10.100.0.0/20"
  private_1_cidr = cidrsubnet(local.cidr_block, 4, 0)
  private_2_cidr = cidrsubnet(local.cidr_block, 4, 1)
  private_3_cidr = cidrsubnet(local.cidr_block, 4, 2)
  public_cidr    = cidrsubnet(local.cidr_block, 4, 3)
  public_1_cidr  = cidrsubnet(local.public_cidr, 3, 0)
  public_2_cidr  = cidrsubnet(local.public_cidr, 3, 1)
  public_3_cidr  = cidrsubnet(local.public_cidr, 3, 2)
  fw_1_cidr      = cidrsubnet(local.public_cidr, 3, 4)
  fw_2_cidr      = cidrsubnet(local.public_cidr, 3, 5)
  fw_3_cidr      = cidrsubnet(local.public_cidr, 3, 6)
}

resource aws_internet_gateway igw {
  vpc_id = aws_vpc.vpc.id
}

resource aws_default_route_table drt {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {"Name": "Public Route Table", "Default": "true"}
}

resource aws_subnet public_az_a {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_1_cidr
  availability_zone       = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {"Name": "${local.vpc_name}-public-a", "use": "public"}
}

resource aws_subnet public_az_b {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_2_cidr
  availability_zone       = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {"Name": "${local.vpc_name}-public-b", "use": "public"}
}

resource aws_subnet public_az_c {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_3_cidr
  availability_zone       = "${local.region}c"
  map_public_ip_on_launch = true

  tags = {"Name": "${local.vpc_name}-public-c", "use": "public"}
}

resource aws_subnet fw_az_a {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.fw_1_cidr
  availability_zone       = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {"Name": "${local.vpc_name}-fw-a", "use": "firewall"}
}

resource aws_subnet fw_az_b {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.fw_2_cidr
  availability_zone       = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {"Name": "${local.vpc_name}-fw-b", "use": "firewall"}
}

resource aws_subnet fw_az_c {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.fw_3_cidr
  availability_zone       = "${local.region}c"
  map_public_ip_on_launch = true

  tags = {"Name": "${local.vpc_name}-fw-c", "use": "firewall"}
}

# resource aws_subnet private_az_a {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = local.private_1_cidr
#   availability_zone       = "${local.region}a"
#   map_public_ip_on_launch = false
#
#   tags = {"Name": "${local.vpc_name}-private-a", "use": "private"}
# }

# resource aws_subnet private_az_b {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = local.private_2_cidr
#   availability_zone       = "${local.region}b"
#   map_public_ip_on_launch = false
#
#   tags = {"Name": "${local.vpc_name}-private-b", "use": "private"}
# }
#
# resource aws_subnet private_az_c {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = local.private_3_cidr
#   availability_zone       = "${local.region}c"
#   map_public_ip_on_launch = false
#
#   tags = {"Name": "${local.vpc_name}-private-c", "use": "private"}
# }

resource aws_vpc_endpoint s3_endpoint {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.us-east-2.s3"
  tags = {
    "Name": "S3 Gateway"
  }
}

# resource aws_vpc_endpoint_route_table_association s3_route {
# //  route_table_id  = var.private_subnet ? aws_route_table.private_table[0].id : aws_default_route_table.drt.id
#   route_table_id  = aws_route_table.private_table.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
# }

resource aws_default_security_group vpc_default {
  vpc_id = aws_vpc.vpc.id

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
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource aws_security_group endpoint {
  name   = "endpoint_sg"
  vpc_id = aws_vpc.vpc.id
}

resource aws_security_group_rule https {
  security_group_id = aws_security_group.endpoint.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [local.cidr_block]
}

resource aws_security_group public_node {
  name   = "public_node_sg"
  vpc_id = aws_vpc.vpc.id
}

resource aws_security_group_rule public_egress {
  security_group_id = aws_security_group.public_node.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_vpc_dhcp_options dhcp {
  domain_name         = "podspace.local"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource aws_vpc_dhcp_options_association set {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
}

resource aws_route_table igw_table {
  vpc_id   = aws_vpc.vpc.id

  route {
    vpc_endpoint_id  = (aws_networkfirewall_firewall.fw.firewall_status[0].sync_states[*].attachment[0].endpoint_id)[0]
    cidr_block       = local.cidr_block
  }

  tags = {
    use = "local"
    Name = "${local.vpc_name}-igw-rt"
  }
}

resource aws_route_table_association igw_fw {
  route_table_id = aws_route_table.igw_table.id
  gateway_id     = aws_internet_gateway.igw.id
}

# resource aws_route igw_fw {
#   route_table_id         = aws_route_table.igw_table.id
#   vpc_endpoint_id        = (aws_networkfirewall_firewall.fw.firewall_status[0].sync_states[*].attachment[0].endpoint_id)[0]
#   destination_cidr_block = local.cidr_block
# }

resource aws_route_table public_table {
  vpc_id   = aws_vpc.vpc.id
  tags = {
    use = "local"
    Name = "${local.vpc_name}-public-rt"
  }
}

resource aws_route public_to_fw {
  route_table_id         = aws_route_table.public_table.id
  vpc_endpoint_id        = (aws_networkfirewall_firewall.fw.firewall_status[0].sync_states[*].attachment[0].endpoint_id)[0]
  destination_cidr_block = "0.0.0.0/0"
}

output fw_status {
  value = aws_networkfirewall_firewall.fw.firewall_status[0].sync_states[*].attachment[0].endpoint_id
}

resource aws_route_table_association public_subnet_a {
  route_table_id = aws_route_table.public_table.id
  subnet_id      = aws_subnet.public_az_a.id
}

resource aws_route_table_association public_subnet_b {
  route_table_id = aws_route_table.public_table.id
  subnet_id      = aws_subnet.public_az_b.id
}

resource aws_route_table_association public_subnet_c {
  route_table_id = aws_route_table.public_table.id
  subnet_id      = aws_subnet.public_az_c.id
}

resource aws_route_table fw_table {
  vpc_id   = aws_vpc.vpc.id
  tags = {
    use = "local"
    Name = "${local.vpc_name}-fw-rt"
  }
}

resource aws_route_table_association fw_subnet_a {
  route_table_id = aws_route_table.fw_table.id
  subnet_id      = aws_subnet.fw_az_a.id
}

resource aws_route_table_association fw_subnet_b {
  route_table_id = aws_route_table.fw_table.id
  subnet_id      = aws_subnet.fw_az_b.id
}

resource aws_route_table_association fw_subnet_c {
  route_table_id = aws_route_table.fw_table.id
  subnet_id      = aws_subnet.fw_az_c.id
}

resource aws_route internet {
  route_table_id         = aws_route_table.fw_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource aws_networkfirewall_firewall fw {
  name                = "fw-b"
  vpc_id              = aws_vpc.vpc.id
  firewall_policy_arn = aws_networkfirewall_firewall_policy.policy.arn
  subnet_mapping {
    subnet_id = aws_subnet.fw_az_b.id
  }
}

resource aws_networkfirewall_firewall_policy policy {
  name = "fw-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:pass", "ExampleCustomAction"]
    stateless_fragment_default_actions = ["aws:drop"]

    stateless_custom_action {
      action_definition {
        publish_metric_action {
          dimension {
            value = "1"
          }
        }
      }
      action_name = "ExampleCustomAction"
    }
  }
}

# resource aws_route_table private_table {
#   vpc_id   = aws_vpc.vpc.id
#   tags = {
#     use = "local"
#     Name = "${local.vpc_name}-private-rt"
#   }
# }
#
# resource aws_route_table_association private_a {
#   subnet_id      = aws_subnet.private_az_a.id
#   route_table_id = aws_route_table.private_table.id
# }
#
# resource aws_route_table_association private_b {
#   subnet_id      = aws_subnet.private_az_b.id
#   route_table_id = aws_route_table.private_table.id
# }
# resource aws_route_table_association private_c {
#   subnet_id      = aws_subnet.private_az_c.id
#   route_table_id = aws_route_table.private_table.id
# }
