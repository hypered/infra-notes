variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

module "amis" {
  source = "./amis"
  env_prefix = "${var.env_prefix}"
  base_image_file = "${path.module}/../../../default.nix"
  base_image_attr = "image"
}

output "nixos_base_ami_id" {
  value = module.amis.nixos_base_ami_id
  description = "The ID of a NixOS base AMI"
}
