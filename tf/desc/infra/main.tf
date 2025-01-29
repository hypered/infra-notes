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

module "ssh" {
  source = "./ssh"
  env_prefix = "${var.env_prefix}"
}

module "web-1" {
  source          = "./instance"
  base_ami        = module.amis.nixos_base_ami_id
  toplevel_file   = "${path.module}/../../../default.nix"
  toplevel_attr   = "web"
  instance_type   = "t3a.small"
  ssh_key_name    = module.ssh.key_name
  ssh_private_key = module.ssh.private_key
  security_groups = [aws_security_group.ssh_security_group.name]
  node_id         = "web-1"
  env_prefix      = var.env_prefix
}

module "gh-runner-1" {
  source          = "./instance"
  base_ami        = module.amis.nixos_base_ami_id
  toplevel_file   = "${path.module}/../../../default.nix"
  toplevel_attr   = "gh-runner"
  instance_type   = "t3a.small"
  ssh_key_name    = module.ssh.key_name
  ssh_private_key = module.ssh.private_key
  security_groups = [aws_security_group.ssh_security_group.name]
  node_id         = "gh-runner-1"
  env_prefix      = var.env_prefix
}

resource "aws_security_group" "ssh_security_group" {
  name        = "${var.env_prefix}-allow-ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access to e.g. cache.nixos.org.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-security-group"
  }
}

# -----------------------------------------------------------------------------
# Outputs

output "web_1_name" {
  value = module.web-1.name
  description = "The name of the EC2 instance"
}

output "web_1_public_ip" {
  value = module.web-1.public_ip
  description = "The public IP address of the EC2 instance"
}

output "gh_runner_1_name" {
  value = module.gh-runner-1.name
  description = "The name of the EC2 instance"
}

output "gh_runner_1_public_ip" {
  value = module.gh-runner-1.public_ip
  description = "The public IP address of the EC2 instance"
}
