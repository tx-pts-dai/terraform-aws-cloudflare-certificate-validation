output "zones" {
  value       = [for zone in data.cloudflare_zone.zone : zone.name]
  description = "values of the zones"
}
