resource tls_private_key ca_key {
  algorithm = "RSA"
}

resource tls_self_signed_cert ca_cert {
  allowed_uses          = ["digital_signature", "cert_signing", "crl_signing"]
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.ca_key.private_key_pem
  validity_period_hours = 365 * 24 * 10
  is_ca_certificate     = true
  subject {
    common_name  = "podspace-ca"
    organization = "podspace.net"
  }
}

resource local_file ca_key {
  filename        = "../secrets/ca_key.pem"
  content         = tls_private_key.ca_key.private_key_pem
  file_permission = 0440
}

resource local_file ca_cert {
  filename = "../secrets/podspace_ca.pem"
  content  = tls_self_signed_cert.ca_cert.cert_pem
}

output ca_key_pem {
  value = tls_private_key.ca_key.private_key_pem
}

output ca_cert_pem {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output ca_name {
  value = local_file.ca_cert.filename
}
