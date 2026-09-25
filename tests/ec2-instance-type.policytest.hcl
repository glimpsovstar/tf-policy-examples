policytest {
  targets = ["ec2-instance-type.policy.hcl"]
}

resource "aws_instance" "approved_size" {
  attrs = {
    instance_type = "t3.micro"
    tags          = { Environment = "Dev" }
  }
}

resource "aws_instance" "approved_larger_size" {
  attrs = {
    instance_type = "t3.medium"
    tags          = { Environment = "Prod" }
  }
}

resource "aws_instance" "oversized" {
  expect_failure = true
  attrs = {
    instance_type = "m5.24xlarge"
    tags          = { Environment = "Dev" }
  }
}

resource "aws_instance" "previous_generation" {
  expect_failure = true
  attrs = {
    instance_type = "t2.micro"
    tags          = { Environment = "Dev" }
  }
}
