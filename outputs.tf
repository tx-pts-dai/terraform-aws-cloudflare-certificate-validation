output "data_validation_record" {
  value       = data.cloudflare_dns_records.validation_record
  description = "value of the validation record"
}

output "local_validation_record" {
  value       = local.validation_records_to_create
  description = "value of the validation record"
}

output "acm_validation_options" {
  value       = module.acm.acm_certificate_domain_validation_options
  description = "value of the validation record"
}
