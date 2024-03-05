#resource aws_default_security_group utility_security_group {
#  vpc_id = module.utility_ohio.vpc_id
#
#  ingress {
#    protocol    = "icmp"
#    from_port   = -1
#    to_port     = -1
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    protocol    = "tcp"
#    from_port   = 22
#    to_port     = 22
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    protocol    = "-1"
#    from_port   = 0
#    to_port     = 0
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
