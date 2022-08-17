/**
 * # 200compute
 */

# terraform block cannot be interpolated; sample provided as output of _main

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    # this key must be unique for each layer!
    bucket  = "999999999999-build-state-bucket"
    key     = "terraform.development.200compute.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# pinned provider versions

provider "aws" {
  version             = "~> 2.35"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "terraform_remote_state" "main_state" {
  backend = "local"

  config = {
    path = "../../_main/terraform.tfstate"
  }
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket  = "999999999999-build-state-bucket"
    key     = "terraform.development.000base.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    bucket  = "999999999999-build-state-bucket"
    key     = "terraform.development.100data.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }

  key_pair_prefix   = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${lower(var.environment)}"
  key_pair_internal = "${local.key_pair_prefix}-internal"
}
