data aws_region current {}

locals {
  region = data.aws_region.current.name
}

module scratch_ohio {
  source = "git::https://github.com/smuggy/terraform-base//aws/network/standard_vpc?ref=main"

  cidr_block     = "10.32.128.0/21"
  domain_name    = "podspace.local"
  region         = local.region
  vpc_name       = "sb-scratch-${local.region}"
  subnet_bits    = 6
  private_subnet = true
}

#module dns_by_name {
#  source = "git::https://github.com/smuggy/terraform-base//aws/network/route53/private_zone?ref=main"
#
#  domain_name = "podspace.local"
#  vpc_ids = {
#    "scratch_ohio" = module.scratch_ohio.vpc_id
#  }
#  zone_name = "private-name"
#  zone_type = "name"
#}

module public_dns {
  source = "git::https://github.com/smuggy/terraform-base//aws/network/route53/public_zone?ref=main"

  domain_name = "podspace.net"
  zone_name   = "public-name"
  zone_type   = "name"
}

#module dns_by_address {
#  source = "git::https://github.com/smuggy/terraform-base//aws/network/route53/private_zone?ref=main"
#
#  domain_name = "32.10.in-addr.arpa"
#  vpc_ids = {
#    "scratch_ohio" = module.scratch_ohio.vpc_id
#  }
#  zone_name = "private-address"
#  zone_type = "reverse"
#}

module private_ca {
  source = "git::https://github.com/smuggy/terraform-base//tls/root_certificate?ref=main"

  common_name  = "podspace.local"
  organization = "podspace"
}

resource local_file private_ca_key {
  filename        = "../secrets/local_ca_key.pem"
  content         = module.private_ca.private_key
  file_permission = 0440
}

resource local_file private_ca_cert {
  filename        = "../secrets/local_ca_cert.pem"
  content         = module.private_ca.certificate_pem
  file_permission = 0444
}

module public_ca {
  source = "git::https://github.com/smuggy/terraform-base//tls/root_certificate?ref=main"

  common_name  = "podspace.net"
  organization = "podspace"
}

resource local_file ca_key {
  filename        = "../secrets/podspace_ca_key.pem"
  content         = module.public_ca.private_key
  file_permission = 0440
}

resource local_file ca_cert {
  filename        = "../secrets/podspace_ca_cert.pem"
  content         = module.public_ca.certificate_pem
  file_permission = 0444
}

//resource null_resource cr4 {
//  triggers = {
//    vpc_id = module.utility.vpc_id
//  }
//  provisioner local-exec {
//    command = "aws route53 list-hosted-zones-by-vpc --region ${local.region} --vpc-region ${local.region} --vpc-id ${module.utility.vpc_id} --output text --query 'HostedZoneSummaries[].[HostedZoneId,Name]' | grep podspace > ${path.module}/t1.out"
//  }
//  provisioner local-exec {
//    command = "a=$(cat t1.out) && echo $(sed 's/ .*//' <<< $a) > t2.out"
//  }
//}
//
//data null_data_source v1 {
//  depends_on = [null_resource.cr4]
//  inputs = {
//    value = fileexists("${path.module}/t2.out") ? file("${path.module}/t2.out") : ""
//  }
//}
//data aws_route53_zone mz {
//  zone_id = chomp(data.null_data_source.v1.outputs["value"])
//}

//module z {
//  source = "./zone_lookup"
//  vpc_id = module.utility.vpc_id
//}

output utility_vpc_id {
  value = module.utility.vpc_id
}

//output zone_d {
//  value = module.z.zone_id
//}
#module kube {
#  source = "./kube"
#}
//module workspaces_1 {
//  source    = "./workspaces"
//  providers = {
//    aws     = aws.nova
//  }
//}
//module bastion {
//  source = "./bastion"
//}
//data aws_caller_identity current {}
//
//data aws_ami windows_amis_2 {
//  count = 1
//  most_recent = true
//  owners = [
//    data.aws_caller_identity.current.account_id]
//  filter {
//    name = "tag:tag1"
//    values = [
//      "aaa"]
//  }
//  filter {
//    name = "tag:tag2"
//    values = [
//      "bbb"]
//  }
//}

//data aws_ami windows_amis {
//  count = 0
//  most_recent = true
//  owners = [data.aws_caller_identity.current.account_id]
//  filter {
//    name   = "tag:tag1"
//    values = ["aaa"]
//  }
//  filter {
//    name   = "tag:tag3"
//    values = ["*"]
//  }
//  filter {
//    name   = "platform"
//    values = ["windows"]
//  }
//  filter {
//    name   = "virtualization-type"
//    values = ["hvm"]
//  }
//  filter {
//    name   = "description"
//    values = ["Microsoft Windows Server 2016 Core Locale English AMI provided by Amazon"]
//  }
//}

//output amazon_windows_ami {
//  value = element(coalescelist(data.aws_ami.windows_amis.*.id, data.aws_ami.windows_amis_2.*.id), 0)
//}

//module workspaces_2 {
//  source    = "./ws-2"
//  providers = {
//    aws     = aws.nova
//  }
//}
//locals {
//  value = "/abc/dev/ghi"
//}

//module t {
//  source = "./env_test"
//}
//
//resource null_resource test {
//  provisioner local-exec {
//    command = "echo ${local.value} | sed 's/\\/dev//'  > v.txt"
//  }
//
//}

resource aws_iam_user prom_user {
  name = "promsa"
}

data aws_iam_policy ec2_access {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource aws_iam_user_policy promsa {
  name = "ec2-access"
  user = aws_iam_user.prom_user.name

  policy = data.aws_iam_policy.ec2_access.policy
}

module utility {
  source = "./utilities"
}
