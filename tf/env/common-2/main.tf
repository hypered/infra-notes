provider "aws" {
  region = "eu-central-1"
}

module "infra" {
  source = "../../desc/common"
  env_prefix = "common"
}

locals {
  outputs = module.infra
}

output "outputs" {
  value = { for k, v in local.outputs : k => v }
}
