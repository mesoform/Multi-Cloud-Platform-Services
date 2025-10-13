terraform{
  backend "gcs"{
    bucket = "gcs-bucket-name"
    prefix  = "tf-state-files"
  }
}

provider "kubernetes" {
  host                   = "https://dummy-gcp-host"
  token                  = "dummy-token"
  cluster_ca_certificate = "dummy-cert"
  insecure               = true
}

module "mcp" {
  source = "source-path"
}