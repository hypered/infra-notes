variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

module "common" {
  source = "../common"
  env_prefix = "${var.env_prefix}"
}

module "infra" {
  source = "../infra"
  env_prefix = "${var.env_prefix}"
  nixos_base_ami_id = module.common.nixos_base_ami_id
}

output "gh_runner_1_public_ip" {
  value = module.infra.gh_runner_1_public_ip
  description = "The public IP address of the EC2 instance"
}
