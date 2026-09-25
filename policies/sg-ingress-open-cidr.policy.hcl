# Converted from aws_demo/restrict-ingress-sg-rule-cidr-blocks.sentinel
#
# No ingress rule may allow the entire internet, on any port. Broader than the
# SSH policy: this is the blanket rule, that one is the specific case worth
# naming in a violation message.
#
# The Sentinel original walked inline ingress blocks with find_blocks and a
# for loop. Here the inline-block case is a separate policy targeting
# aws_security_group, because tfpolicy dispatches per resource type.

input "forbidden_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

resource_policy "aws_security_group_rule" "no_open_ingress_cidr" {
  enforcement_level = "advisory"

  filter = core::try(attrs.type, "") == "ingress"

  locals {
    cidrs = core::try(attrs.cidr_blocks, [])
    open  = core::contains(local.cidrs, input.forbidden_cidr)
  }

  enforce {
    condition     = !local.open
    error_message = "${core::try(meta.address, "aws_security_group_rule")} allows ingress from ${input.forbidden_cidr}. Ingress must come from a known range."
  }
}

resource_policy "aws_vpc_security_group_ingress_rule" "no_open_ingress_cidr" {
  enforcement_level = "advisory"

  locals {
    cidr = core::try(attrs.cidr_ipv4, "")
    open = local.cidr == input.forbidden_cidr
  }

  enforce {
    condition     = !local.open
    error_message = "${core::try(meta.address, "aws_vpc_security_group_ingress_rule")} allows ingress from ${input.forbidden_cidr}. Ingress must come from a known range."
  }
}

# Inline ingress blocks on the security group itself. Blocks are list-shaped
# even when singular, so this reads attrs.ingress as a list.
resource_policy "aws_security_group" "no_open_inline_ingress" {
  enforcement_level = "advisory"

  locals {
    ingress_blocks = core::try(attrs.ingress, [])
    open_blocks    = [for r in local.ingress_blocks : r if core::contains(core::try(r.cidr_blocks, []), input.forbidden_cidr)]
    open_count     = core::length(local.open_blocks)
  }

  enforce {
    condition     = local.open_count == 0
    error_message = "${core::try(meta.address, "aws_security_group")} has ${local.open_count} inline ingress block(s) allowing ${input.forbidden_cidr}."
  }
}
