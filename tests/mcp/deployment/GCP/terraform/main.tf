terraform{
  backend "gcs"{
    bucket = "gcs-bucket-name"
    prefix  = "tf-state-files"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  alias       = "gke"
}

module "mcp" {
  source = "source-path"
}