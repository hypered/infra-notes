variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

module "amis" {
  source = "./amis"
  env_prefix = "${var.env_prefix}"
  base_image_file = "${path.module}/../../default.nix"
  base_image_attr = "image"
}

module "ssh" {
  source = "./ssh"
  env_prefix = "${var.env_prefix}"
}

module "node-1" {
  source          = "./instance"
  base_ami        = module.amis.nixos_base_ami_id
  toplevel_file   = "${path.module}/../../default.nix"
  toplevel_attr   = "toplevel"
  instance_type   = "t2.xlarge"
  ssh_key_name    = module.ssh.key_name
  ssh_private_key = module.ssh.private_key
  security_groups = [aws_security_group.ssh_security_group.name]
  node_id         = "node-1"
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

output "node_1_name" {
  value = module.node-1.name
  description = "The name of the EC2 instance"
}

output "node_1_public_ip" {
  value = module.node-1.public_ip
  description = "The public IP address of the EC2 instance"
}
