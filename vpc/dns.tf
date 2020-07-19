resource aws_route53_zone internal {
  name = "internal.podspace.net"
  vpc {
    vpc_id = module.kube.vpc_id
  }
  vpc {
    vpc_id = module.utility.vpc_id
  }
//  vpc {
//    vpc_id = module.bastion.vpc_id
//  }
}

resource aws_route53_zone reverse {
  name = "20.10.in-addr.arpa"
  vpc {
    vpc_id = module.kube.vpc_id
  }
  vpc {
    vpc_id = module.utility.vpc_id
  }
//  vpc {
//    vpc_id = module.bastion.vpc_id
//  }
}
