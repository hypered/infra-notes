variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "base_image_file" {
  description = "File where the NixOS toplevel for the AMI defined"
  type        = string
}

variable "base_image_attr" {
  description = "Attribute for the NixOS base toplevel for the AMI"
  type        = string
}

module "s3" {
  source = "../s3"
  env_prefix = "${var.env_prefix}"
}

module "toplevel" {
  source    = "github.com/noteed/nixos-anywhere//terraform/nix-build"
  file      = var.base_image_file
  attribute = var.base_image_attr
  nix_argstrs = {
    env_prefix = var.env_prefix
  }
}

# -----------------------------------------------------------------------------
# Our own AMI. The goal is to have a base image that is more similar to
# our toplevels, to minimise uploads to the target machine.
resource "aws_ami" "nixos-base" {
  name                = "${var.env_prefix}-nixos-base"
  architecture        = "x86_64"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  ena_support         = true
  sriov_net_support   = "simple"

  ebs_block_device {
    device_name           = "/dev/xvda"
    snapshot_id           = aws_ebs_snapshot_import.nixos-base.id
    volume_size           = 40
    delete_on_termination = true
    volume_type           = "gp3"
  }
}

resource "aws_s3_bucket_object" "nixos-base-ami" {
  bucket = module.s3.amis_bucket
  key    = "${var.env_prefix}-nixos-base.vhd"

  source      = "${module.toplevel.result.out}/nixos-amazon-image-23.05pre-git-x86_64-linux.vhd"
  source_hash = filemd5("${module.toplevel.result.out}/nixos-amazon-image-23.05pre-git-x86_64-linux.vhd")
}

resource "aws_ebs_snapshot_import" "nixos-base" {
  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = module.s3.amis_bucket
      s3_key    = aws_s3_bucket_object.nixos-base-ami.key
    }
  }

  role_name = module.s3.ami_import_role_name

  tags = {
    Name = "${var.env_prefix}-nixos-base"
  }
}

# -----------------------------------------------------------------------------
# Find the latest NixOS AMI published by https://github.com/NixOS/amis.
data "aws_ami" "nixos-latest_x86_64" {
  # The owner value is documented at https://nixos.github.io/amis/.
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/24.05*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

output "nixos_base_ami_id" {
  value = aws_ami.nixos-base.id
}
