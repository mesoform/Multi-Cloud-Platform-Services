terraform{
  backend "gcs"{
    bucket = "gcs-bucket-name"
    prefix  = "tf-state-files"
  }
}

provider "kubernetes" {
}

module "mcp" {
  source = "../../../../../"
#  source = "source-path"
}