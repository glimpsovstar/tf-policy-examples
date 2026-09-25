# Converted from aws_demo/check-ec2-environment-tag.sentinel
#
# Every EC2 instance must carry an Environment tag whose value is on the
# allowed list. The Sentinel original used two filter helpers and counted
# messages; tfpolicy expresses the same intent as two independent enforce
# blocks, so a resource missing the tag and a resource with a bad value give
# different, actionable messages.

input "allowed_environments" {
  type    = list(string)
  default = ["Dev", "Test", "Prod"]
}

resource_policy "aws_instance" "environment_tag" {
  enforcement_level = "advisory"

  locals {
    tags      = core::try(attrs.tags, {})
    tag_keys  = core::keys(local.tags)
    has_env   = core::contains(local.tag_keys, "Environment")
    env_value = core::try(local.tags["Environment"], "")
    value_ok  = core::contains(input.allowed_environments, local.env_value)
  }

  enforce {
    condition     = local.has_env
    error_message = "${core::try(meta.address, "aws_instance")} has no Environment tag. Required tags identify who owns a resource and which environment it belongs to."
  }

  # Passes when the tag is absent so the two checks report independently -
  # the block above already covers absence.
  enforce {
    condition     = !local.has_env || local.value_ok
    error_message = "${core::try(meta.address, "aws_instance")} has Environment=\"${local.env_value}\", which is not one of: ${core::join(", ", input.allowed_environments)}."
  }
}
