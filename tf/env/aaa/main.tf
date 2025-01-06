provider "aws" {
  region = "eu-central-1"
}

#terraform {
#  backend "s3" {
#    region         = "eu-central-1"
#    bucket         = "terraform.state.xyz"
#    key            = "envs/aaa.tfstate"
#    dynamodb_table = "terraform.lock"
#    encrypt        = true
#  }
#}

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
