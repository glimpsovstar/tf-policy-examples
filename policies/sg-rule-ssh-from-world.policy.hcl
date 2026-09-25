# Converted from aws_demo/restrict-ingress-sg-rule-ssh.sentinel
#
# SSH must not be reachable from the whole internet.
#
# The Sentinel original ran to ~90 lines because it hand-rolled four port-range
# permutations with explicit null checks. The same logic is one boolean here:
# a rule exposes SSH when its port range spans 22, which covers every case the
# original enumerated. core::try handles the nulls.

input "forbidden_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

input "ssh_port" {
  type    = number
  default = 22
}

# Legacy standalone rule resource.
resource_policy "aws_security_group_rule" "no_ssh_from_world" {
  enforcement_level = "advisory"

  filter = core::try(attrs.type, "") == "ingress"

  locals {
    cidrs      = core::try(attrs.cidr_blocks, [])
    open       = core::contains(local.cidrs, input.forbidden_cidr)
    from_port  = core::try(attrs.from_port, 0)
    to_port    = core::try(attrs.to_port, 65535)
    spans_ssh  = local.from_port <= input.ssh_port && local.to_port >= input.ssh_port
    is_violation = local.open && local.spans_ssh
  }

  enforce {
    condition     = !local.is_violation
    error_message = "${core::try(meta.address, "aws_security_group_rule")} opens port range ${local.from_port}-${local.to_port} to ${input.forbidden_cidr}, exposing SSH (${input.ssh_port}) to the internet."
  }
}

# Modern per-rule resource, which is what terraform-aws-rhel-instance uses.
resource_policy "aws_vpc_security_group_ingress_rule" "no_ssh_from_world" {
  enforcement_level = "advisory"

  locals {
    cidr         = core::try(attrs.cidr_ipv4, "")
    open         = local.cidr == input.forbidden_cidr
    from_port    = core::try(attrs.from_port, 0)
    to_port      = core::try(attrs.to_port, 65535)
    spans_ssh    = local.from_port <= input.ssh_port && local.to_port >= input.ssh_port
    is_violation = local.open && local.spans_ssh
  }

  enforce {
    condition     = !local.is_violation
    error_message = "${core::try(meta.address, "aws_vpc_security_group_ingress_rule")} opens port range ${local.from_port}-${local.to_port} to ${input.forbidden_cidr}, exposing SSH (${input.ssh_port}) to the internet."
  }
}
