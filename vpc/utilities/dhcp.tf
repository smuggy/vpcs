#resource aws_vpc_dhcp_options utility {
#  domain_name         = "podspace.internal"
#  domain_name_servers = ["AmazonProvidedDNS"]
#}
#
#resource aws_vpc_dhcp_options_association set {
#  vpc_id          = module.utility_ohio.vpc_id
#  dhcp_options_id = aws_vpc_dhcp_options.utility.id
#}