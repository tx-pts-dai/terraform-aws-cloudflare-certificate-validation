locals {
  domains = keys(var.records_map)
  validation_records = {
    for idx, domain in local.domains : domain => {
      zone_id = data.cloudflare_zone.zone[domain].zone_id
      name    = trimsuffix(module.acm.acm_certificate_domain_validation_options[idx].resource_record_name, ".")
      value   = trimsuffix(module.acm.acm_certificate_domain_validation_options[idx].resource_record_value, ".")
      type    = module.acm.acm_certificate_domain_validation_options[idx].resource_record_type
    }
  }
}
