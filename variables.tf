variable "dns_records" {
  description = <<EOT
A map of DNS records, where each key represents a unique identifier for the record.
Each value is an object containing:
  - subdomain: The subdomain for the DNS record.
  - zone: The DNS zone associated with the record.
EOT
  type = map(object({
    subdomain = string
    zone      = string
  }))
}

variable "enable_validation" {
  description = "Whether to create validation records in Cloudflare"
  type        = bool
  default     = true
}

variable "acm_certificate" {
  description = "The ACM certificate data containing domain validation options"
  type = object({
    arn = string
    domain_validation_options = list(object({
      domain_name           = string
      resource_record_name  = string
      resource_record_type  = string
      resource_record_value = string
    }))
  })
}

variable "cloudflare_secret_name" {
  description = <<EOT
The name of the AWS Secrets Manager secret containing the Cloudflare API token.
Should be in json format:
{"accountId":"XXXXXXXXXXXXXXXXXXXXX","apiToken":"ABCDEFGHIJKLMNOPQRSTUVWXYZ"}
EOT
  type        = string
}
