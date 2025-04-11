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
  required_version = ">= 1.6.0"
}


data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = var.cloudflare_secret_name
}

data "cloudflare_zone" "zone" {
  for_each = var.dns_records
  filter = {
    name       = each.value.zone
    account_id = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["accountId"]
    match      = "any"
  }
}

data "aws_caller_identity" "current" {}

locals {
  domains = keys(var.dns_records)
  validation_records = {
    for idx, domain in local.domains : domain => {
      zone_id = data.cloudflare_zone.zone[domain].zone_id
      name    = trimsuffix(module.acm.acm_certificate_domain_validation_options[idx].resource_record_name, ".")
      value   = trimsuffix(module.acm.acm_certificate_domain_validation_options[idx].resource_record_value, ".")
      type    = module.acm.acm_certificate_domain_validation_options[idx].resource_record_type
    }
  }
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

resource "null_resource" "validation_records" {
  for_each = var.enable_validation ? local.validation_records : {}
  provisioner "local-exec" {
    command = <<-EOF
      curl -X POST "https://api.cloudflare.com/client/v4/zones/${each.value.zone_id}/dns_records" \
      -H "Authorization: Bearer ${jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]}" \
      -H "Content-Type: application/json" \
      --data '{
        "type": "${each.value.type}",
        "name": "${each.value.name}",
        "content": "${each.value.value}",
        "comment": "ACM validation for account ${data.aws_caller_identity.current.account_id}",
        "ttl": 300,
        "proxied": false
      }'
    EOF
  }

  depends_on = [
    module.acm
  ]
}

resource "aws_acm_certificate_validation" "acm" {
  count           = var.enable_validation ? 1 : 0
  certificate_arn = module.acm.acm_certificate_arn

  validation_record_fqdns = [for record in local.validation_records : record.name]

  depends_on = [
    null_resource.validation_records
  ]
}
