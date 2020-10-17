resource aws_default_security_group kube_vpc_default {
  vpc_id = aws_vpc.kubernetes.id

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group endpoint {
  name   = "endpoint_sg"
  vpc_id = aws_vpc.kubernetes.id
}

resource aws_security_group_rule https {
  security_group_id = aws_security_group.endpoint.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["10.20.16.0/20"]
}