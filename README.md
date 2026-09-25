# tf-policy-examples

AWS guardrails written in **Terraform Policy (tfpolicy)** — the native `.policy.hcl` engine —
converted from the Sentinel policies in
[`glimpsovstar/terraform-sentinel-policies/aws_demo`](https://github.com/glimpsovstar/terraform-sentinel-policies/tree/main/aws_demo).

✅ **Validated and tested** with `tfpolicy` 0.3.0. `tfpolicy validate` fetches the AWS
provider schema and checks every policy against it; `tfpolicy test` runs the mocks in
`tests/`. Both pass, and CI enforces them on every push.

## What was converted

| Sentinel (`aws_demo`) | tfpolicy | Notes |
|---|---|---|
| `check-ec2-environment-tag.sentinel` | `ec2-environment-tag.policy.hcl` | Two `enforce` blocks so "tag missing" and "tag has a bad value" report differently |
| `restrict-current-ec2-instance-type.sentinel` | `ec2-instance-type.policy.hcl` | Original read `tfstate`; this evaluates the **plan**, so violations are caught before apply |
| `restrict-ingress-sg-rule-ssh.sentinel` | `sg-rule-ssh-from-world.policy.hcl` | ~90 lines of hand-rolled port permutations become one boolean |
| `restrict-ingress-sg-rule-cidr-blocks.sentinel` | `sg-ingress-open-cidr.policy.hcl` | Inline `ingress` blocks split into their own policy, since tfpolicy dispatches per resource type |
| `require-most-recent-AMI-version.sentinel` | *not converted* | It was already commented out of `sentinel.hcl` |

Both security-group policies also cover **`aws_vpc_security_group_ingress_rule`**, the modern
per-rule resource. The Sentinel originals predate it and only handle
`aws_security_group_rule` and inline blocks — so they would miss a violation created by
current Terraform code, including
[`terraform-aws-rhel-instance`](https://github.com/glimpsovstar/terraform-aws-rhel-instance).

## The port-range simplification

The Sentinel SSH policy enumerated four permutations of null and non-null `from_port` /
`to_port`, each with its own branch and print statements. The whole thing reduces to:

```hcl
spans_ssh = local.from_port <= input.ssh_port && local.to_port >= input.ssh_port
```

A rule exposes SSH when its port range spans 22. `core::try` supplies defaults for the null
cases the original branched on.

## Tuning without editing policies

Every threshold is an `input`, so a consumer overrides values rather than forking:

| Input | Default |
|---|---|
| `allowed_environments` | `["Dev", "Test", "Prod"]` |
| `allowed_instance_types` | `["t3.micro", "t3.small", "t3.medium"]` |
| `forbidden_cidr` | `"0.0.0.0/0"` |
| `ssh_port` | `22` |

## Enforcement levels

All policies are **`advisory`**, matching the Sentinel originals — they report without
blocking. Switch to `mandatory_overridable` or `mandatory` to make them gate a run.

The stronger demo is `mandatory`: request an oversized instance, or open SSH to the world,
and watch the run fail on policy rather than on a human noticing in review.

## Validating

Install the CLI from [releases.hashicorp.com/tfpolicy](https://releases.hashicorp.com/tfpolicy/),
then:

```bash
tfpolicy validate --policies=./policies
tfpolicy test     --policies=./policies --tests=./tests
```

Trust the exit code, not the trailing "Success!" line — it can print even when individual
diagnostics raised exit 1.

### Three things validation caught

Worth recording, because none are obvious from the language reference:

1. **`input` blocks are global to the policy directory**, not scoped per file. Declaring
   `forbidden_cidr` in two policies is a "Duplicate input block" error — hence
   `_inputs.policy.hcl`.
2. **Every file containing resource or provider policies needs its own `policy` block with
   `required_providers`.** Without it: *"No provider schema is available for resource type
   aws_instance."* It is a nested block of `policy`, not of `terraform_config`.
3. **Provider versions want both bounds.** `>= 5.0` warns; `>= 6.0.0, < 7.0.0` is clean.
   Policies pin the schema they are checked against, which is the opposite of the advice for
   modules, where `>=` maximises consumer compatibility.

## Layout

```text
policies/   *.policy.hcl      the guardrails
tests/      *.policytest.hcl  mock resources, expected pass/fail per policy
```
