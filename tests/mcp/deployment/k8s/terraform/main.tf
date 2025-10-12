terraform{
  backend "gcs"{
    bucket = "gcs-bucket-name"
    prefix  = "tf-state-files"
  }
}

provider "kubernetes" {
  load_config_file = true
}

module "mcp" {
  source = "../../../../../"
#  source = "source-path"
}