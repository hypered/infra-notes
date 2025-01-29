# -----------------------------------------------------------------------------
# Initial access to the VM

variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

resource "aws_key_pair" "initial_key" {
    key_name   = "${var.env_prefix}-initial-key-${sha256(tls_private_key.state_ssh_key.public_key_openssh)}"
    public_key = tls_private_key.state_ssh_key.public_key_openssh
}

resource "tls_private_key" "state_ssh_key" {
    algorithm = "RSA"
}

resource "local_file" "initial_ssh_key" {
    sensitive_content = tls_private_key.state_ssh_key.private_key_pem
    filename          = "${path.module}/${var.env_prefix}-id_rsa.pem"
    file_permission   = "0600"
}

output "key_name" {
  value = aws_key_pair.initial_key.key_name
  description = "An initial SSH key to be installed when using the base image"
}

output "private_key" {
  value = tls_private_key.state_ssh_key.private_key_pem
  description = "An initial SSH key to be installed when using the base image"
}
