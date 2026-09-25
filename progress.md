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

- Decide enforcement level: advisory reports, mandatory gates the run.
- Wire into the demo workspaces.

## Key context

- **Validated with tfpolicy 0.3.0**, from https://releases.hashicorp.com/tfpolicy/ (not from
  the repo named in the skill, which 404s). `validate` and `test` both exit 0. CI installs
  the same version and runs both on every push.
- Three errors only the real binary surfaced:
  1. `input` blocks are **global to the policy directory**, so duplicates across files fail.
     Shared inputs live in `_inputs.policy.hcl`.
  2. Every file with resource or provider policies needs its own `policy` block containing
     `required_providers` — nested in `policy`, **not** in `terraform_config`, which was the
     wrong guess. Without it: "No provider schema is available for resource type ...".
  3. Provider versions should bound both ends. Policies pin the schema they are checked
     against — the opposite of the module guidance, where `>=` maximises compatibility.
- Language rules that shaped the code: every built-in needs the `core::` prefix; optional
  attributes must be wrapped in `core::try` or evaluation errors occur that
  `expect_failure` does **not** cleanly catch; conditions must be single-line; blocks are
  list-shaped even when singular; `meta.address` is undefined under `tfpolicy test`, so all
  message interpolations wrap it in `core::try`.
- The Sentinel originals' SSH port logic (four branches) collapses to one boolean:
  `from_port <= 22 && to_port >= 22`.
