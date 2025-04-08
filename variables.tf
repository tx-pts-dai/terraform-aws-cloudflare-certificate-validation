variable "cloudflare_secret_id" {
  description = "The secret ID for the Cloudflare API token stored in AWS Secrets Manager"
  type        = string
}

variable "records_map" {
  description = "A map of records split with subdomain and zone information"
  type = map(object({
    subdomain = string
    zone      = string
  }))
}

variable "create_validation_records" {
  description = "Whether to create validation records in Cloudflare"
  type        = bool
  default     = true
}
