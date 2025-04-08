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

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = local.domains[0]
  subject_alternative_names = slice(local.domains, 1, length(local.domains))

  validation_method = "DNS"

  create_route53_records = false
  validate_certificate   = false
}

resource "null_resource" "validation_records" {
  for_each = var.create_validation_records ? local.validation_records : {}
  provisioner "local-exec" {
    command = <<-EOF
      curl -X POST "https://api.cloudflare.com/client/v4/zones/${each.value.zone_id}/dns_records" \
      -H "Authorization: Bearer ${jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]}" \
      -H "Content-Type: application/json" \
      --data '{
        "type": "${each.value.type}",
        "name": "${each.value.name}",
        "content": "${each.value.value}",
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
  certificate_arn = module.acm.acm_certificate_arn

  validation_record_fqdns = [for record in local.validation_records : record.name]

  depends_on = [
    null_resource.validation_records
  ]
}

# NOT NECESSARY !
# resource "null_resource" "validation_records_delete" {
#   for_each = local.validation_records

#   provisioner "local-exec" {
#     command = <<-EOF
#       curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${each.value.zone_id}/dns_records" \
#       -H "Authorization: Bearer ${jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]}" \
#       -H "Content-Type: application/json" \
#       --data '{
#         "type": "${each.value.type}",
#         "name": "${each.value.name}",
#         "content": "${each.value.value}",
#         "ttl": 300,
#         "proxied": false
#       }'
#     EOF
#   }

#   depends_on = [
#     aws_acm_certificate_validation.acm
#   ]
# }
