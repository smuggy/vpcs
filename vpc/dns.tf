//resource aws_route53_delegation_set nameservers {
//  reference_name = "podspace_default"
//}

//resource aws_route53_zone internal {
//  name = "internal.podspace.net"
//
//  vpc {
//    vpc_id = module.kube.vpc_id
//  }
//  vpc {
//    vpc_id = module.utility.vpc_id
//  }
////  vpc {
////    vpc_id = module.bastion.vpc_id
////  }
//  tags = {
//    ZoneType = "name"
//  }
//}

//resource aws_route53_zone reverse {
//  name = "20.10.in-addr.arpa"
//  vpc {
//    vpc_id = module.kube.vpc_id
//  }
//  vpc {
//    vpc_id = module.utility.vpc_id
//  }
//  tags = {
//    ZoneType = "reverse"
//  }
//}

//
// updated name.com to include the nameservers used by this zone.
// normally, the nameservers for the domain in name.com are:
//   * ns1.name.com
//   * ns2.name.com
//   * ns3.name.com
//   * ns4.name.com
//
//resource aws_route53_zone public {
//  name = "podspace.net"
//
//  delegation_set_id = aws_route53_delegation_set.nameservers.id
//  tags = {
//    ZoneType = "name"
//  }
//}
//
//  vpc {
//    vpc_id = module.bastion.vpc_id
//  }
