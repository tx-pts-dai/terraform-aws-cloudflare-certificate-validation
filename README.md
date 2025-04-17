# Terraform AWS DNS Validation Module

This Terraform module automates the creation of DNS validation records for ACM certificates using AWS and Cloudflare.

## Important

This module handles validation records creation idempotently, meaning certificates with potentially the same DNS specifications will force recreation of validation records if they don't exist yet. If they already exist, the certificate will be validated through those records.

It leverages the `null_resource` and `local-exec` provisioner to interact with the Cloudflare API for DNS record management. However, even after a `terraform destroy`, the null resource does not remove previously created validation records. To fully clean up the resources, you **must** manually delete the Cloudflare records.

## Limits

AWS ACM certificates need to be renewed once a year. To automatically handle the renewal, the DNS validation records must still exist. If automatic certificate renewal fails and you receive an email from AWS (usually 30 to 60 days before expiration), first check whether these records have been manually removed. If they have, you will need to recreate them.

One simple way is by renaming the `null_resource.validation_records` so it forces recreation.

## Usage

Below is an example of how to use this module (see `examples/complete` for full example):

```hcl
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = local.domains[0]
  subject_alternative_names = length(local.domains) > 1 ? slice(local.domains, 1, length(local.domains)) : []

  validation_method = "DNS"

  create_route53_records = false
  validate_certificate   = false
}

module "dns" {
  source                 = "tx-pts-dai/cloudflare-dns-validation/aws"
  enable_validation      = true # default is true
  cloudflare_secret_name = "dai/cloudflare/apiToken"
  dns_records            = local.dns_records
  acm_certificate = {
    arn                       = module.acm.acm_certificate_arn
    domain_validation_options = module.acm.acm_certificate_domain_validation_options
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
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate_validation.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [null_resource.validation_records](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret_version.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [cloudflare_zone.zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate"></a> [acm\_certificate](#input\_acm\_certificate) | The ACM certificate data containing domain validation options | <pre>object({<br/>    arn = string<br/>    domain_validation_options = list(object({<br/>      domain_name           = string<br/>      resource_record_name  = string<br/>      resource_record_type  = string<br/>      resource_record_value = string<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_cloudflare_secret_name"></a> [cloudflare\_secret\_name](#input\_cloudflare\_secret\_name) | The name of the AWS Secrets Manager secret holding the Cloudflare API token.<br/>Should be in json format:<br/>{"accountId":"XXXXXXXXXXXXXXXXXXXXX","apiToken":"ABCDEFGHIJKLMNOPQRSTUVWXYZ"} | `string` | n/a | yes |
| <a name="input_dns_records"></a> [dns\_records](#input\_dns\_records) | A map of DNS records, where each key represents a unique identifier for the record.<br/>Each value is an object containing:<br/>  - subdomain: The subdomain for the DNS record.<br/>  - zone: The DNS zone associated with the record. | <pre>map(object({<br/>    subdomain = string<br/>    zone      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_enable_validation"></a> [enable\_validation](#input\_enable\_validation) | Whether to create validation records in Cloudflare | `bool` | `true` | no |
| <a name="input_recreate_validation_records"></a> [recreate\_validation\_records](#input\_recreate\_validation\_records) | Whether to force recreation of validation records in Cloudflare | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauvererd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Francisco Ferreira](https://github.com/cferrera), [Roland Bapst](https://github.com/rbapst-tamedia) and [Samuel Wibrow](https://github.com/swibrow)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
