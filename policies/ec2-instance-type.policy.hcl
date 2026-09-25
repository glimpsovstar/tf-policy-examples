# Converted from aws_demo/restrict-current-ec2-instance-type.sentinel
#
# Only instance types on the approved menu may be provisioned. The Sentinel
# original read tfstate; tfpolicy evaluates planned attributes, so this catches
# the violation before it is applied rather than after.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
}

resource_policy "aws_instance" "allowed_instance_type" {
  enforcement_level = "advisory"

  locals {
    instance_type = core::try(attrs.instance_type, "")
    is_allowed    = core::contains(input.allowed_instance_types, local.instance_type)
  }

  enforce {
    condition     = local.is_allowed
    error_message = "${core::try(meta.address, "aws_instance")} requests instance type \"${local.instance_type}\", which is not on the approved list: ${core::join(", ", input.allowed_instance_types)}."
    info_message  = "Instance type \"${local.instance_type}\" is approved."
  }
}
