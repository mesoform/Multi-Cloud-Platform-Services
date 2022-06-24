//noinspection HILUnresolvedReference
locals {
  cloudrun_default = {
    metadata = {
      annotations = {
        "run.googleapis.com/client-name"    = "terraform"
        "run.googleapis.com/ingress"        = "all"
        "run.googleapis.com/ingress-status" = "all"

      }
    }
    template_metadata = {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1000"
        "run.googleapis.com/client-name" = "terraform"
      }
    }
    traffic = {
      latest = 100
    }
  }
  user_cloudrun_config_yml  = fileexists(var.gcp_cloudrun_yml) ? file(var.gcp_cloudrun_yml) : null
  cloudrun                  = try(yamldecode(local.user_cloudrun_config_yml), {})
  cloudrun_components       = lookup(local.cloudrun, "components", {})
  cloudrun_components_specs = lookup(local.cloudrun_components, "specs", {})

  // Makes error for var.gcp_cloudrun_traffic if not configured so it is skipped and the traffic file is used
  cloudrun_traffic_config   = try(var.gcp_cloudrun_traffic != null ? var.gcp_cloudrun_traffic : yamldecode(var.gcp_cloudrun_traffic) , yamldecode(file(var.gcp_cloudrun_traffic_yml)), {})
  cloudrun_secret_config_yml = fileexists(var.gcp_cloudrun_secrets_yml) ? sensitive(file(var.gcp_cloudrun_secrets_yml)): null
  cloudrun_secrets = sensitive(try(yamldecode(local.cloudrun_secret_config_yml), {}))
  #Removing sensitve values for configuring the secrets (not the secret data)
  cloudrun_secrets_existing = { for secret, config in local.cloudrun_secrets: secret => {project = lookup(config, "project", null)} if !lookup(config, "create", false )} # if create is false
  cloudrun_secrets_create = {
    for secret, config in local.cloudrun_secrets: secret =>
      {for key, value in config: key => value if key != "secret_data"}
    if lookup(config, "create", false )}
  secret_projects = toset(concat([for secret in local.cloudrun_secrets : secret.project if lookup(secret, "project", null ) != null], [local.cloudrun.project_id]))
  cloudrun_specs = {
    for key, specs in local.cloudrun_components_specs:
      key => merge(lookup(local.cloudrun_components, "common", {}), specs)
  }
  cloudrun_iam = {
    for key, specs in local.cloudrun_specs:
      key => lookup(local.cloudrun_specs[key], "iam", {})
  }
  cloudrun_iam_bindings = {
    for key, specs in local.cloudrun_iam:
      key => lookup(local.cloudrun_iam[key], "bindings", {})
  }

//  cloudrun_traffic = local.cloudrun_traffic_config == {} ? {} : {
  cloudrun_traffic = {
    for service, specs in local.cloudrun_specs: service => {
      for revision, percent in local.cloudrun_traffic_config: replace(revision, ";", "-") => percent
      if length(regexall("^${service};", revision)) > 0
    }
  }

  cloudrun_secrets_attach = {
    for service, specs in local.cloudrun_specs: service => {
      for secret, config in lookup(specs, "secrets", {}): secret => config
    }
  }

  cloudrun_secrets_env = {
    for service, secrets in local.cloudrun_secrets_attach: service => {
      for secret, config in secrets: secret => config
        if lookup(config, "env_name", null) != null

    }
  }
  cloudrun_secrets_mount = {
    for service, secrets in local.cloudrun_secrets_attach: service => {
      for secret, config in secrets: secret => config
        if lookup(config, "mount_location", null) != null
    }
  }

  cloudrun_domains = {
    for key, specs in local.cloudrun_specs : key => specs
    if lookup(local.cloudrun_specs[key], "domain", null) != null
  }
}
