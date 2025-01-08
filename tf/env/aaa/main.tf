provider "aws" {
  region = "eu-central-1"
}

module "infra" {
  source = "../../desc"
  env_prefix = "aaa"
}

locals {
  outputs = module.infra
}

output "outputs" {
  value = { for k, v in local.outputs : k => v }
}
