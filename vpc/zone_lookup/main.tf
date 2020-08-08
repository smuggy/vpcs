variable vpc_id {
}

data aws_region current {}

locals {
  region = data.aws_region.current.name
}

resource null_resource cr {
  triggers = {
    vpc_id = var.vpc_id
  }
  provisioner local-exec {
    command = "aws route53 list-hosted-zones-by-vpc --region ${local.region} --vpc-region ${local.region} --vpc-id ${var.vpc_id} --output text --query 'HostedZoneSummaries[].[HostedZoneId,Name]' | grep podspace > ${path.module}/t1.out"
  }
  provisioner local-exec {
    command = "a=$(cat ${path.module}/t1.out) && echo $(sed 's/ .*//' <<< $a) > ${path.module}/t2.out"
  }
}

data null_data_source v1 {
  depends_on = [null_resource.cr]
  inputs = {
    value = file("${path.module}/t2.out")
  }
}

data aws_route53_zone mz {
  zone_id = chomp(data.null_data_source.v1.outputs["value"])
}

output zone_id {
  value = data.null_data_source.v1.outputs["value"]
}
