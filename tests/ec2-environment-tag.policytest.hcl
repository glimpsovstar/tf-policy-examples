policytest {
  targets = ["ec2-environment-tag.policy.hcl"]
}

resource "aws_instance" "tagged_correctly" {
  attrs = {
    instance_type = "t3.micro"
    tags = {
      Name        = "ha-demo-001"
      Environment = "Dev"
    }
  }
}

resource "aws_instance" "missing_environment_tag" {
  expect_failure = true
  attrs = {
    instance_type = "t3.micro"
    tags = {
      Name = "ha-demo-002"
    }
  }
}

resource "aws_instance" "invalid_environment_value" {
  expect_failure = true
  attrs = {
    instance_type = "t3.micro"
    tags = {
      Name        = "ha-demo-003"
      Environment = "Staging"
    }
  }
}

# core::try(attrs.tags, {}) must handle a resource with no tags at all
# rather than raising an evaluation error.
resource "aws_instance" "no_tags_at_all" {
  expect_failure = true
  attrs = {
    instance_type = "t3.micro"
  }
}
