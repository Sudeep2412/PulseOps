resource "aws_security_group" "pulseops_host" {
  name        = "launch-wizard-4"
  description = "launch-wizard-4 created 2026-11-01T09:24:39.777Z"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.authorized_ssh_cidrs
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {}

  lifecycle {
    prevent_destroy = true
  }
}
