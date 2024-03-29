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
