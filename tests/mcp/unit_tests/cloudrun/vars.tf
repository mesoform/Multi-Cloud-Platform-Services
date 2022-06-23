variable gcp_cloudrun_yml {
  description = "path to YAML file containing congifuation for GAE Applications/Services"
  type = string
  default = "resources/gcp_cloudrun.yml"
}

variable user_project_config_yml {
  type = string
  default = "resources/project.yml"
}

variable gcp_cloudrun_traffic_yml {
  default = "resources/gcp_cloudrun_traffic.yml"
}

variable gcp_cloudrun_traffic {
  default = null
}
variable gcp_cloudrun_secrets_yml {
  description = "Path to YAML file containing traffic configuration for Cloud Run "
  type        = string
  default     = "resources/gcp_cloudrun_secrets.yml"
}