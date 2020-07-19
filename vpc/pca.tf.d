data aws_region current {}

locals {
  region       = data.aws_region.current.name
  signing_algo = "SHA256WITHRSA"
  ca_enabled   = false
}

resource aws_acmpca_certificate_authority root {
  type    = "ROOT"
  enabled = local.ca_enabled

  certificate_authority_configuration {
    key_algorithm     = "RSA_2048"
    signing_algorithm = local.signing_algo
    subject {
      common_name = "podspace.net"
    }
  }
  permanent_deletion_time_in_days = 7
  tags = {
    CostCenter = 308
    Name       = "my-root-cert"
    Domain     = "Infra"
  }
}

resource null_resource sign_ca {
  count = local.ca_enabled == true ? 1 : 0

  triggers = {
    certificate_id = aws_acmpca_certificate_authority.root.id
  }

  # issue the certificate
  provisioner local-exec {
    command = "aws acm-pca issue-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.root.arn} --template-arn arn:aws:acm-pca:::template/RootCACertificate/V1 --signing-algorithm ${local.signing_algo} --validity Value=10,Type=YEARS --csr \"${aws_acmpca_certificate_authority.root.certificate_signing_request}\" --output text > ${path.module}/certificate-arn.out"
  }

  # get the newly issued certificate
  provisioner local-exec {
    command = "certarn=$(cat ${path.module}/certificate-arn.out) && aws acm-pca get-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.root.arn} --certificate-arn \"$certarn\" --output text > ${path.module}/certificate.pem"
  }

  # get the import the certificate to activate
  provisioner local-exec {
    command = "cert=$(cat ${path.module}/certificate.pem) && aws acm-pca import-certificate-authority-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.root.arn} --certificate \"$cert\""
  }
}

output cert_arn {
  value = aws_acmpca_certificate_authority.root.arn
}

output csr {
  value = aws_acmpca_certificate_authority.root.certificate_signing_request
}
