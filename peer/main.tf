data aws_vpc utility_vpc {
  tags = {
    Name = "utility-us-east-2-vpc"
  }
}

data aws_vpc kube_vpc {
  tags = {
    Name = "kube-us-east-2-vpc"
  }
}

data aws_route_tables acc_rts {
  vpc_id = local.accepter_id
}

data aws_route_tables req_rts {
  vpc_id = local.requester_id
}

locals {
  accepter_id    = data.aws_vpc.utility_vpc.id
  accepter_cidr  = data.aws_vpc.utility_vpc.cidr_block
  requester_id   = data.aws_vpc.kube_vpc.id
  requester_cidr = data.aws_vpc.kube_vpc.cidr_block
}

resource aws_vpc_peering_connection auto_pc {
  auto_accept = true
  vpc_id      = local.requester_id
  peer_vpc_id = local.accepter_id
}

resource aws_route req_route {
  for_each                  = data.aws_route_tables.req_rts.ids
  route_table_id            = each.value
  destination_cidr_block    = local.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.auto_pc.id
}

resource aws_route acc_route {
  for_each = data.aws_route_tables.acc_rts.ids
  route_table_id            = each.value
  destination_cidr_block    = local.requester_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.auto_pc.id
}
