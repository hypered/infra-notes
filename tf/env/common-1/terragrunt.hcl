generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "eu-central-1"
}
EOF
}

terraform {
  source = "${get_path_to_repo_root()}/tf/desc//common"
}

inputs = {
  env_prefix = "common"
}
