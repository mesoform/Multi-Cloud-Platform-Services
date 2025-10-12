provider "kubernetes" {
  host                   = "dummy-host"
  token                  = "dummy-token"
  cluster_ca_certificate = "dummy-cert"
  insecure               = true
  load_config_file       = false
}

module "mcp" {
  source  = "../../mcp"
}
