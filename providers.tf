provider "aws" {
  region = "eu-central-1"
}

provider "cloudflare" {
  api_token = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string)["apiToken"]
}
