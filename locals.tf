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
  validation_records_to_create = {
    for _, record in module.acm.acm_certificate_domain_validation_options : record.domain_name => {
      name  = trimsuffix(record.resource_record_name, ".")
      type  = record.resource_record_type
      value = record.resource_record_value
    } if length(lookup(data.cloudflare_dns_records.validation_record, record.domain_name, { result = [] }).result) == 0
  }
}
