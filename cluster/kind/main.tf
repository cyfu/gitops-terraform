terraform {
  required_version = ">= 1.10.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.4.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.5.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.7.0"
    }
  }
}

# ==========================================
# Construct KinD cluster
# ==========================================

resource "kind_cluster" "this" {
  name           = "flux-e2e"
  node_image     = "kindest/node:v1.31.2"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }
  }
}

# ==========================================
# Initialise a Github project
# ==========================================

resource "github_repository" "this" {
  name        = var.github_repository
  description = var.github_repository
  visibility  = "public"
  auto_init   = true # This is extremely important as flux_bootstrap_git will not work without a repository that has been initialised
}

# ==========================================
# Bootstrap KinD cluster
# ==========================================

resource "flux_bootstrap_git" "this" {
  depends_on = [
    github_repository.this,
    kind_cluster.this
  ]

  embedded_manifests = true
  path               = "clusters/my-cluster"
}
