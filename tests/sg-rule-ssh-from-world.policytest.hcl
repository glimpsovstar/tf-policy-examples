policytest {
  targets = ["sg-rule-ssh-from-world.policy.hcl"]
}

# --- legacy aws_security_group_rule ---

resource "aws_security_group_rule" "ssh_from_office" {
  attrs = {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]
  }
}

resource "aws_security_group_rule" "ssh_from_world" {
  expect_failure = true
  attrs = {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The case the Sentinel original needed four branches for: a wide range that
# happens to span 22.
resource "aws_security_group_rule" "wide_range_spanning_ssh" {
  expect_failure = true
  attrs = {
    type        = "ingress"
    from_port   = 0
    to_port     = 1024
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Open to the world but nowhere near SSH - this policy must not fire.
# sg-ingress-open-cidr is the policy that objects to it.
resource "aws_security_group_rule" "https_from_world" {
  attrs = {
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Egress is out of scope - the filter must exclude it.
resource "aws_security_group_rule" "egress_all" {
  attrs = {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- modern aws_vpc_security_group_ingress_rule ---

resource "aws_vpc_security_group_ingress_rule" "ssh_restricted" {
  attrs = {
    cidr_ipv4   = "192.168.0.0/24"
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_open_to_world" {
  expect_failure = true
  attrs = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
  }
}
