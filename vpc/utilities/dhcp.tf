resource aws_vpc_dhcp_options utility {
  domain_name         = "internal.podspace.net"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource aws_vpc_dhcp_options_association set {
  vpc_id          = aws_vpc.utility.id
  dhcp_options_id = aws_vpc_dhcp_options.utility.id
}