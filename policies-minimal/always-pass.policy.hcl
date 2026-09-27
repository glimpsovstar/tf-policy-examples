# Smallest thing that can possibly work: no provider requirements, no inputs,
# no locals, a condition that is literally true. Used to answer one question -
# can HCP Terraform evaluate a tfpolicy set from this repo at all?
resource_policy "terraform_data" "always_pass" {
  enforcement_level = "advisory"

  enforce {
    condition     = true
    error_message = "unreachable"
    info_message  = "minimal tfpolicy evaluated"
  }
}
