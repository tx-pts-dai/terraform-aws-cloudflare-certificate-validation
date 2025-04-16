terraform {
  backend "s3" {
    bucket               = "tf-state-911453050078"
    key                  = "cloudflare/examples/complete.tfstate"
    workspace_key_prefix = "terraform-aws-cloudflare-certificate-validation"
    dynamodb_table       = "terraform-lock"
    region               = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.11"
}
provider "aws" {
  region = "eu-central-1"
}
locals {
  dns_records = {
    "foo.examples.tamedia.ch" = {
      subdomain = "foo.examples"
      zone      = "tamedia.ch"
    }
    # "foo.examples.tamedia.tech" = {
    #   subdomain = "foo.examples"
    #   zone      = "tamedia.tech"
    # }
  }
  domains = keys(local.dns_records)
}
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = local.domains[0]
  subject_alternative_names = length(local.domains) > 1 ? slice(local.domains, 1, length(local.domains)) : []

  validation_method = "DNS"

  create_route53_records = false
  validate_certificate   = false
}

module "dns" {
  source = "../../"
  # enable_validation      = true # default is true
  dns_records = local.dns_records
  # acm_certificate = {
  #   arn                       = module.acm.acm_certificate_arn
  #   domain_validation_options = module.acm.acm_certificate_domain_validation_options
  # }
}

provider "cloudflare" {
  api_token = jsondecode(data.aws_secretsmanager_secret_version.cloudflare.secret_string)["apiToken"]
}

data "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = "dai/cloudflare/apiToken"
}
