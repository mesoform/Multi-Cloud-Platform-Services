provider "kubernetes" {
  config_path = "~/.kube/config"
  alias       = "gke"
}

module "mcp" {
  source  = "../../mcp"
}
