# Set GitLab CI/CD variables
resource "gitlab_project_variable" "bastion_host" {
  project = var.gitlab_project_id
  key     = "BASTION_HOST"
  value   = aws_instance.bastion.public_ip
}

# resource "gitlab_project_variable" "ssh_private_key_part1" {
#   project   = var.gitlab_project_id
#   key       = "SSH_PRIVATE_KEY_PART1"
#   value     = substr(tls_private_key.final_project_key.private_key_pem, 0, 1000)
#   protected = true
# }

# resource "gitlab_project_variable" "ssh_private_key_part2" {
#   project   = var.gitlab_project_id
#   key       = "SSH_PRIVATE_KEY_PART2"
#   value     = substr(tls_private_key.final_project_key.private_key_pem, 1000, 1000)
#   protected = true
# }

# resource "gitlab_project_variable" "ssh_private_key_part3" {
#   project   = var.gitlab_project_id
#   key       = "SSH_PRIVATE_KEY_PART3"
#   value     = substr(tls_private_key.final_project_key.private_key_pem, 2000, 1000)
#   protected = true
# }

resource "gitlab_project_variable" "ssh_known_hosts" {
  project = var.gitlab_project_id
  key     = "SSH_KNOWN_HOSTS"
  value   = "${aws_instance.bastion.public_ip} ${tls_private_key.final_project_key.public_key_openssh}"
}

resource "gitlab_project_variable" "gitlab_token" {
  project   = var.gitlab_project_id
  key       = "GITLAB_TOKEN"
  value     = var.gitlab_token
  protected = true
  masked    = true
}

resource "gitlab_project_variable" "gitlab_user" {
  project = var.gitlab_project_id
  key     = "GITLAB_USER"
  value   = var.gitlab_user
}

