provider "aws" {
  region = "eu-central-1"
}

module "remote-state" {
  source = "../../desc/state"
}

locals {
  outputs = module.remote-state
}

output "outputs" {
  value = { for k, v in local.outputs : k => v }
}
