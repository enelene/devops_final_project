variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = "quizweb.online"
}

variable "key_name" {
  default = "final_project_key"
}

variable "aws_region" {
  description = "region for aws provider"
  type        = string
  default     = "eu-central-1"
}

variable "gitlab_token" {
  description = "GitLab personal access token"
  type        = string
}

variable "gitlab_project_id" {
  description = "GitLab project ID"
  type        = string
}

variable "gitlab_user" {
  description = "GitLab username"
  type        = string
}


