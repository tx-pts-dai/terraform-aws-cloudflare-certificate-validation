variable "cloudflare_secret_name" {
  description = "AWS secret name holding the CloudFlare API token"
  type        = string
}

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
