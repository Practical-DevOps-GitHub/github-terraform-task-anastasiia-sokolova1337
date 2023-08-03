provider "github" {
  token = var.token
  owner = "Practical-DevOps-GitHub"
}

variable "token" {
  type      = string
  sensitive = true
}

variable "repository_name" {
  description = "(Required) The name of the repository."
  type        = string
  default     = "github-terraform-task-anastasiia-sokolova1337"
}

resource "github_repository_collaborator" "collaborator" {
  username   = "softservedata"
  permission = "admin"
  repository = var.repository_name
}

resource "github_branch" "develop" {
  repository    = var.repository_name
  branch        = "develop"
  source_branch = "main"
}

resource "github_branch_default" "this" {
  branch     = "develop"
  repository = var.repository_name
  depends_on = [github_branch.develop]
}

resource "github_branch_protection" "main" {
  pattern       = "main"
  repository_id = var.repository_name
  required_pull_request_reviews {
    require_code_owner_reviews = true
  }
}

resource "github_branch_protection" "develop" {
  pattern       = "develop"
  repository_id = var.repository_name
  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "github_repository_deploy_key" "deploy_key" {
  key        = tls_private_key.deploy_key.public_key_openssh
  repository = var.repository_name
  title      = "DEPLOY_KEY"
}


