generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "eu-central-1"
}
EOF
}

# Make sure we can access default.nix file in the Terragrunt cache.
include "root" {
  path   = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${path_relative_from_include()}//tf/desc/common"
}

inputs = {
  env_prefix = "common"
}
