Use terraform to create a kind cluster and bootstrap flux CD.

variable "github_token" {
  description = "GitHub Personal Access Token. Give it admin access so that it can create/delete repo, read/write contents"
}

variable "github_org" {
  description = "GitHub organization. For personal account, it's your user name"
}

variable "github_repository" {
  description = "GitHub repository to be created for flux CD bootrap"
}

```
terraform init
terraform apply
```