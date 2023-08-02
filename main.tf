provider "github" {
  token = var.token
  owner = "Practical-DevOps-GitHub"
}

variable "token" {
  type = string
  sensitive = true
}

variable "repository_name" {
  description = "(Required) The name of the repository."
  type        = string
  default = "github-terraform-task-anastasiia-sokolova1337"
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

resource "github_branch_protection" "this" {
  pattern       = ""
  repository_id = ""
}




