data aws_region current {}

locals {
  region = data.aws_region.current.name
}

module utility {
  source = "./utilities"
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
module kube {
  source = "./kube"
}
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
