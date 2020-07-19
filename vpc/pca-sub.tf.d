locals {
  cert_enabled = false
}

resource aws_acmpca_certificate_authority subordinate {
  enabled = local.cert_enabled

  certificate_authority_configuration {
    key_algorithm     = "RSA_2048"
    signing_algorithm = local.signing_algo
    subject {
      common_name = "podspace.net"
    }
  }

  permanent_deletion_time_in_days = 7
  depends_on = [aws_acmpca_certificate_authority.root]
}

resource null_resource sign_sub_cert {
  count = local.cert_enabled == true ? 1 : 0

  depends_on = [null_resource.sign_ca]

  triggers = {
    certificate_id = aws_acmpca_certificate_authority.subordinate.id
  }

  # issue the certificate
  provisioner local-exec {
    command = "aws acm-pca issue-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.root.arn} --template-arn arn:aws:acm-pca:::template/SubordinateCACertificate_PathLen0/V1 --signing-algorithm ${local.signing_algo} --validity Value=1,Type=YEARS --csr \"${aws_acmpca_certificate_authority.subordinate.certificate_signing_request}\" --output text > ${path.module}/certificate-sub-arn.out"
  }

  # get the newly issued certificate
  provisioner local-exec {
    command = "certarn=$(cat ${path.module}/certificate-sub-arn.out) && aws acm-pca get-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.root.arn} --certificate-arn \"$certarn\" --output text > ${local.cert_file}"
  }

  provisioner local-exec {
    command = "awk '/\t/ {split($0, l, \"\t\"); a=1; print l[1]} {if (a==0) print $0}' certificate-sub.pem > cert-sub.pem"
  }

  provisioner local-exec {
    command = "awk '/\t/ {split($0, l, \"\t\"); a=1; print l[2]} {if (a==1) a=2; else if (a==2) print $0}' certificate-sub.pem > chain-sub.pem"
  }

  provisioner local-exec {
    command = "cert=$(cat cert-sub.pem) && chain=$(cat chain-sub.pem) && aws acm-pca import-certificate-authority-certificate --region ${local.region} --certificate-authority-arn ${aws_acmpca_certificate_authority.subordinate.arn} --certificate \"$cert\" --certificate-chain \"$chain\""
  }
}

locals {
  cert_file = "${path.module}/certificate-sub.pem"
}
