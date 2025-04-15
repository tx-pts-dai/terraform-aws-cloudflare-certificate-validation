# Terraform AWS DNS Validation Module

This Terraform module automates the creation of DNS validation records for ACM certificates using AWS and Cloudflare.

## Important

This module handles validation records creation idempotently, meaning certificates with potentially the same DNS specifications will force recreation of validation records if they don't exist yet. If they already exist, the certificate will be validated through those records.

It leverages the `null_resource` and `local-exec` provisioner to interact with the Cloudflare API for DNS record management. However, even after a `terraform destroy`, the null resource does not remove previously created validation records. To fully clean up the resources, you **must** manually delete the Cloudflare records.

## Limits

AWS ACM certificates need to be renewed once a year. To automatically handle the renewal, the DNS validation records must still exist. If automatic certificate renewal fails and you receive an email from AWS (usually 30 to 60 days before expiration), first check whether these records have been manually removed. If they have, you will need to recreate them.

One simple way is by renaming the `null_resource.validation_records` so it forces recreation.

## Usage

Below is an example of how to use this module:

```hcl
provider "aws" {
  region = "eu-central-1"

provider "cloudflare" {
  api_token = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]
}

module "dns_validation" {
  source = ""tx-pts-dai/cloudflare-dns-validation/aws""

  cloudflare_secret_name = "cloudflare-secret-name"
  dns_records = {
    "foo.examples.domain.ch" = {
      subdomain = "foo.examples"
      zone      = "domain.ch"
    }
  }
}
```

## Features

- Creates AWS ACM certificate
- Creates DNS validation records in Cloudflare
- Supports multiple validation records using a map of subdomains and zones
- Integrates with AWS Secrets Manager to securely retrieve the Cloudflare API token

## Examples

You can find examples in the [`examples/`](./examples/) folder. Each subfolder contains a specific use case with a detailed explanation.

### Pre-Commit

Installation: [install pre-commit](https://pre-commit.com/) and execute `pre-commit install`. This will generate pre-commit hooks according to the config in `.pre-commit-config.yaml`

Before submitting a PR be sure to have used the pre-commit hooks or run: `pre-commit run -a`

The `pre-commit` command will run:

- Terraform fmt
- Terraform validate
- Terraform docs
- Terraform validate with tflint
- check for merge conflicts
- fix end of files

as described in the `.pre-commit-config.yaml` file

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_version.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [cloudflare_zone.zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_secret_name"></a> [cloudflare\_secret\_name](#input\_cloudflare\_secret\_name) | AWS secret name holding the CloudFlare API token | `string` | n/a | yes |
| <a name="input_dns_records"></a> [dns\_records](#input\_dns\_records) | A map of DNS records, where each key represents a unique identifier for the record.<br/>Each value is an object containing:<br/>  - subdomain: The subdomain for the DNS record.<br/>  - zone: The DNS zone associated with the record. | <pre>map(object({<br/>    subdomain = string<br/>    zone      = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_zones"></a> [zones](#output\_zones) | values of the zones |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Francisco Ferreira](https://github.com/cferrera), [Roland Bapst](https://github.com/rbapst-tamedia) and [Samuel Wibrow](https://github.com/swibrow)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
