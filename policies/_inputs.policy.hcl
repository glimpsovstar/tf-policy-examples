# Shared inputs.
#
# input blocks are global across the policy directory, not scoped per file -
# defining the same name twice is a "Duplicate input block" error. They live
# here so every policy can reference them and consumers have one place to
# override thresholds without forking a policy.

input "allowed_environments" {
  type    = list(string)
  default = ["Dev", "Test", "Prod"]
}

input "allowed_instance_types" {
  type    = list(string)
  default = ["t3.micro", "t3.small", "t3.medium"]
}

input "forbidden_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

input "ssh_port" {
  type    = number
  default = 22
}
