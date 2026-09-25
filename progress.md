# progress.md

## Goal / scope

AWS guardrails in Terraform Policy (tfpolicy), converted from the Sentinel `aws_demo` set,
for the Home Affairs demo's policy-as-code story.

## Done

- Four `.policy.hcl` files converting every active policy in `aws_demo`.
- Four `.policytest.hcl` files with pass and `expect_failure` mocks.
- Coverage extended to `aws_vpc_security_group_ingress_rule`, which the Sentinel originals
  predate and therefore miss.

## Next

- **Validate.** Nothing here has been run.
- Decide enforcement level: advisory reports, mandatory gates the run.
- Wire into the demo workspaces once validated.

## Key context

- **Unvalidated.** The `tfpolicy` CLI is not installed and is not obtainable from
  `CloudbrokerAz/terraform-policy-core` (404 - private or renamed). Terraform 1.14.4 has no
  `--policies` flag either. Written to the spec in the `tf-policy` skill of
  `terraform-agentic-workflows`, but unexecuted.
- Language rules that shaped the code: every built-in needs the `core::` prefix; optional
  attributes must be wrapped in `core::try` or evaluation errors occur that
  `expect_failure` does **not** cleanly catch; conditions must be single-line; blocks are
  list-shaped even when singular; `meta.address` is undefined under `tfpolicy test`, so all
  message interpolations wrap it in `core::try`.
- The Sentinel originals' SSH port logic (four branches) collapses to one boolean:
  `from_port <= 22 && to_port >= 22`.
