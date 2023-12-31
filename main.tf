provider "github" {
  token = var.token
  owner = var.organisation
}

variable "token" {
  type      = string
  sensitive = true
}

variable "organisation" {
  type    = string
  default = "Practical-DevOps-GitHub"
}

variable "repository_name" {
  description = "(Required) The name of the repository."
  type        = string
  default     = "github-terraform-task-anastasiia-sokolova1337"
}

variable "collaborators" {
  type = map(string)
  default = {
    "softservedata" = "admin"
  }
}

variable "branches" {
  type    = set(string)
  default = ["main", "develop"]
}

variable "discord_webhook_events" {
  type    = list(string)
  default = ["pull_request", "pull_request_review", "pull_request_review_comment", "pull_request_review_thread", "push"]
}

variable "action_token" {
  type      = string
  sensitive = true
}

resource "github_repository_collaborator" "collaborator" {
  for_each = var.collaborators

  username   = each.key
  permission = each.value
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
    require_code_owner_reviews      = true
    required_approving_review_count = 0
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

resource "github_repository_file" "pull_request_template" {
  for_each            = var.branches
  content             = <<EOT
  ## Describe your changes

  ## Issue ticket number and link

  ## Checklist before requesting a review
  - [ ] I have performed a self-review of my code
  - [ ] If it is a core feature, I have added thorough tests
  - [ ] Do we need to implement analytics?
  - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOT
  file                = ".github/pull_request_template.md"
  repository          = var.repository_name
  overwrite_on_create = true
  branch              = each.key
}

resource "github_repository_file" "codeowners_main" {
  content             = <<EOT
  * @softservedata
  EOT
  file                = "CODEOWNERS"
  repository          = var.repository_name
  branch              = "main"
  overwrite_on_create = true
}

resource "github_repository_webhook" "discord_server" {
  events     = var.discord_webhook_events
  repository = var.repository_name
  configuration {
    content_type = "json"
    url          = "https://discord.com/api/webhooks/1136580082283069510/UYOZaNngZYIDZMg8djjnFwFnetmcsML3RtvpGW74DRFTDEQ86EcvDQxYbMtFrzb9PO1_/github"
  }
}

resource "github_actions_secret" "pat" {
  repository      = var.repository_name
  secret_name     = "PAT"
  plaintext_value = var.action_token
}
