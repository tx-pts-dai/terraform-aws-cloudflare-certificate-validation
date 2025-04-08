# Terraform AWS DNS Validation Module

This Terraform module automates the creation of DNS validation records for ACM certificates using AWS and Cloudflare.

## Important

This module handles validation records creation idempotently, meaning certificates with potentially the same DNS specifications will force recreation of validation records if they don't exist yet. If they already exist, the certificate will be validated through those records.

It leverages the `null_resource` and `local-exec` provisioner to interact with the Cloudflare API for DNS record management. However, even after a `terraform destroy`, the null resource does not remove previously created validation records. To fully clean up the resources, you **must** manually delete the Cloudflare records.

## Limits

AWS ACM certificates need to be renewed once a year. To automatically handle the renewal, the DNS validation records must still exist. If automatic certificate renewal fails and you receive an email from AWS (usually 30 to 60 days before expiration), first check whether these records have been manually removed. If they have, you will need to recreate them.

## Usage

Below is an example of how to use this module:

```hcl
module "dns_validation" {
  source = "github.com/your-repo/terraform-aws-dns-validation"

  cloudflare_secret_id = "your-cloudflare-secret-id"
  records_map = {
    "foo.examples.domain.ch" = {
      subdomain = "foo.examples"
      zone      = "domain.ch"
    }
  }
}
```

## Features

- Automatically creates AWS ACM certificate for DNS records
- Automatically creates DNS validation records in Cloudflare for ACM certificates.
- Supports multiple validation records using a map of subdomains and zones.
- Integrates with AWS Secrets Manager to securely retrieve the Cloudflare API token.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 5.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate_validation.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [null_resource.validation_records](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_secretsmanager_secret_version.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [cloudflare_dns_records.validation_record](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/dns_records) | data source |
| [cloudflare_zone.zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_secret_id"></a> [cloudflare\_secret\_id](#input\_cloudflare\_secret\_id) | The secret ID for the Cloudflare API token stored in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_create_validation_records"></a> [create\_validation\_records](#input\_create\_validation\_records) | Whether to create validation records in Cloudflare | `bool` | `true` | no |
| <a name="input_records_map"></a> [records\_map](#input\_records\_map) | A map of records split with subdomain and zone information | <pre>map(object({<br/>    subdomain = string<br/>    zone      = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_validation_options"></a> [acm\_validation\_options](#output\_acm\_validation\_options) | value of the validation record |
| <a name="output_data_validation_record"></a> [data\_validation\_record](#output\_data\_validation\_record) | value of the validation record |
| <a name="output_local_validation_record"></a> [local\_validation\_record](#output\_local\_validation\_record) | value of the validation record |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Demetrio Carrara](https://github.com/sgametrio) and [Roland Bapst](https://github.com/rbapst-tamedia)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
