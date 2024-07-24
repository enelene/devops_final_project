# Create a new RSA private key
resource "tls_private_key" "final_project_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new key pair in AWS using the public key from the private key
resource "aws_key_pair" "final_project_key" {
  key_name   = var.key_name
  public_key = tls_private_key.final_project_key.public_key_openssh
}

# Save the private key locally to a file
resource "local_file" "private_key" {
  content         = tls_private_key.final_project_key.private_key_pem
  filename        = "${path.module}/final_project_key.pem"
  file_permission = "0400"
}
