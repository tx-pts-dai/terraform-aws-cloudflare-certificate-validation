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

module "dns" {
  source               = "../../"
  enable_validation    = true # default is true
  cloudflare_secret_id = "dai/cloudflare/apiToken"
  dns_records = {
    "foo.examples.tamedia.ch" = {
      subdomain = "foo.examples"
      zone      = "tamedia.ch"
    }
    "foo.examples.tamedia.tech" = {
      subdomain = "foo.examples"
      zone      = "tamedia.tech"
    }
  }
}
