terraform {
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
  source                    = "../../"
  create_validation_records = true # default is true
  cloudflare_secret_id      = "dai/cloudflare/apiToken"
  records_map = {
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
