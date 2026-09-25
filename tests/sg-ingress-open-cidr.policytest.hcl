policytest {
  targets = ["sg-ingress-open-cidr.policy.hcl"]
}

resource "aws_security_group_rule" "restricted" {
  attrs = {
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_security_group_rule" "open_to_world" {
  expect_failure = true
  attrs = {
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "open_to_world_modern" {
  expect_failure = true
  attrs = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
  }
}

# Inline ingress blocks. Blocks are list-shaped even when singular.
resource "aws_security_group" "inline_restricted" {
  attrs = {
    name = "restricted"
    ingress = [{
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["192.168.0.0/24"]
    }]
  }
}

resource "aws_security_group" "inline_open" {
  expect_failure = true
  attrs = {
    name = "too-open"
    ingress = [{
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  }
}

# A group with no inline ingress at all must not raise an evaluation error.
resource "aws_security_group" "no_inline_ingress" {
  attrs = {
    name = "rules-defined-separately"
  }
}
