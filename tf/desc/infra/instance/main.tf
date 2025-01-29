resource "aws_instance" "node" {
  ami           = var.base_ami
  instance_type = var.instance_type

  key_name        = var.ssh_key_name
  security_groups = var.security_groups

  tags = {
    Name = "${var.env_prefix}-${var.node_id}"
  }
}

module "toplevel" {
  source    = "github.com/noteed/nixos-anywhere//terraform/nix-build"
  file      = var.toplevel_file
  attribute = var.toplevel_attr
  nix_argstrs = {
    env_prefix = var.env_prefix
  }
}

module "deploy" {
  source          = "github.com/noteed/nixos-anywhere//terraform/nixos-rebuild"
  nixos_system    = module.toplevel.result.out
  target_host     = aws_instance.node.public_ip
  ssh_private_key = var.ssh_private_key
}

variable "env_prefix" {
  description = "Environment prefix for the resource tags"
  type        = string
  default     = "prod"
}

variable "base_ami" {
  description = "AMI ID for the instance base image"
  type        = string
}

variable "toplevel_file" {
  description = "File where the NixOS toplevel for the instance is defined"
  type        = string
}

variable "toplevel_attr" {
  description = "Attribute for the NixOS toplevel for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key to use"
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key content"
  type        = string
}

variable "security_groups" {
  description = "List of security group names for the EC2 instance"
  type        = list(string)
}

variable "node_id" {
  description = "Identifier for the node"
  type        = string
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.node.public_ip
}

output "node_id" {
  description = "Node identifier"
  value       = var.node_id
}

output "name" {
  description = "Complete node name"
  value       = aws_instance.node.tags["Name"]
}
