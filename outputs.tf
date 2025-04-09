output "validation_record" {
  value       = module.acm.acm_certificate_domain_validation_options
  description = "value of the validation record(s)"
}

output "acm_certificate_arn" {
  value       = module.acm.acm_certificate_arn
  description = "ARN of the ACM certificate"
}
