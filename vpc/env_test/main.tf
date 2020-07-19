variable test_env_value {
  default = "default value"
}

resource null_resource test {
  provisioner local-exec {
    command = "echo ${var.test_env_value}"
  }
}
