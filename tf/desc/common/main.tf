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
