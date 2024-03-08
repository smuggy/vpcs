resource aws_route53_delegation_set nameservers {
  reference_name = "podspace_default"
}

module private_ca {
  source = "git::https://github.com/smuggy/terraform-base//tls/root_certificate?ref=main"

  common_name  = "podspace.internal"
  organization = "podspace"
}

resource local_file private_ca_key {
  filename        = "../secrets/internal_ca_key.pem"
  content         = module.private_ca.private_key
  file_permission = 0440
}

resource local_file private_ca_cert {
  filename        = "../secrets/internal_ca_cert.pem"
  content         = module.private_ca.certificate_pem
  file_permission = 0444
}

module public_ca {
  source = "git::https://github.com/smuggy/terraform-base//tls/root_certificate?ref=main"

  common_name  = "podspace.net"
  organization = "podspace"
  hours_valid  = 87600
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
