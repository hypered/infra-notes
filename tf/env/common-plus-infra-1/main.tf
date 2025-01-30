provider "aws" {
  region = "eu-central-1"
}

module "common-plus-infra" {
  source = "../../desc/common-plus-infra"
  env_prefix = "aaa"
}

locals {
  outputs = module.common-plus-infra
}

output "outputs" {
  value = { for k, v in local.outputs : k => v }
}
