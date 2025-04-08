data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = var.cloudflare_secret_id
}

data "cloudflare_zone" "zone" {
  for_each = var.records_map

  filter = {
    name = each.value.zone
  }
}

data "cloudflare_dns_records" "validation_record" {
  for_each = var.records_map

  zone_id = data.cloudflare_zone.zone[each.key].zone_id

  name = {
    exact = module.acm.acm_certificate_domain_validation_options[0].domain_name
  }
}
