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


# data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
#   secret_id = var.cloudflare_secret_name
# }

data "cloudflare_zone" "zone" {
  for_each = var.dns_records

  filter = {
    name = each.value.zone
  }
}

# data "cloudflare_zones" "example_zones" {
#   for_each = var.dns_records
#   account = {
#     id = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["accountId"]
#   }
#   direction = "desc"
#   name      = each.value.zone
#   order     = "status"
#   status    = "initializing"
# }

# data "aws_caller_identity" "current" {}

locals {
  # domains = keys(var.dns_records)
  # validation_records = {
  #   for idx, domain in local.domains : domain => {
  #     zone_id = data.cloudflare_zone.zone[domain].zone_id
  #     name    = trimsuffix(var.acm_certificate.domain_validation_options[idx].resource_record_name, ".")
  #     value   = trimsuffix(var.acm_certificate.domain_validation_options[idx].resource_record_value, ".")
  #     type    = var.acm_certificate.domain_validation_options[idx].resource_record_type
  #   }
  # }
}

# resource "null_resource" "validation_records" {
#   for_each = var.enable_validation ? local.validation_records : {}
#   provisioner "local-exec" {
#     command = <<-EOF
#       curl -X POST "https://api.cloudflare.com/client/v4/zones/${each.value.zone_id}/dns_records" \
#       -H "Authorization: Bearer ${jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]}" \
#       -H "Content-Type: application/json" \
#       --data '{
#         "type": "${each.value.type}",
#         "name": "${each.value.name}",
#         "content": "${each.value.value}",
#         "comment": "ACM validation for account ${data.aws_caller_identity.current.account_id}",
#         "ttl": 300,
#         "proxied": false
#       }'
#     EOF
#   }
# }

# resource "aws_acm_certificate_validation" "acm" {
#   count           = var.enable_validation ? 1 : 0
#   certificate_arn = var.acm_certificate.arn

#   validation_record_fqdns = [for record in local.validation_records : record.name]

#   depends_on = [
#     null_resource.validation_records
#   ]
# }

provider "aws" {
  region = "eu-central-1"
}
