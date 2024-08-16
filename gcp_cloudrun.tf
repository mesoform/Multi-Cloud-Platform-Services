//noinspection HILUnresolvedReference
resource google_cloud_run_service self {
  provider = google-beta
  for_each = local.cloudrun_specs
  location = local.cloudrun.location_id
  name     = each.value.name
  project  = local.cloudrun["project_id"]
  autogenerate_revision_name = local.cloudrun_autogenerate_revision_name[each.key]
  //noinspection HILUnresolvedReference
  dynamic metadata {
    for_each = {metadata = lookup(each.value,"metadata",{})}
    content{
      annotations      = merge(local.cloudrun_default.metadata.annotations, lookup(metadata.value, "annotations", {} ))
      generation       = lookup(metadata.value, "generation", null)
      labels           = lookup(metadata.value, "labels", null)
      namespace        = lookup(metadata.value, "namespace", null)
      resource_version = lookup(metadata.value, "resource_version", null)
      self_link        = lookup(metadata.value, "self_link", null)
      uid              = lookup(metadata.value, "uid", null)
    }
  }
  template {
    //noinspection HILUnresolvedReference
    spec {
      container_concurrency = lookup(each.value.template, "container_concurrency", 80)
      timeout_seconds       = lookup(each.value.template, "timeout_seconds", null)
      service_account_name  = lookup(each.value.template, "service_account_name", null)
      //noinspection HILUnresolvedReference
      containers {
        image   = each.value.template.containers.image
        args    = lookup(each.value.template.containers, "args", null)
        command = lookup(each.value.template.containers, "command", null)
        //noinspection HILUnresolvedReference
        dynamic "ports" {
          for_each = lookup(each.value.template.containers, "ports", {})
          content {
            name           = lookup(ports.value, "name", null)
            protocol       = lookup(ports.value, "protocol", null)
            container_port = ports.value.container_port
          }
        }
        //noinspection HILUnresolvedReference
        dynamic "resources" {
          for_each = lookup(each.value.template.containers, "resources", null) == null ? {} : { resources : each.value.template.containers.resources }
          content {
            limits   = lookup(resources.value, "limits", null)
            requests = lookup(resources.value, "requests", null)
          }
        }
        //noinspection HILUnresolvedReference
        dynamic "env" {
          for_each = lookup(each.value.template.containers, "environment_vars", {})
          content {
            name  = env.key
            value = env.value
          }
        }
        dynamic "env" { # secret environment variables
          for_each = local.cloudrun_secrets_env[each.key]
          content {
            name = env.value["env_name"]
            value_from {
              secret_key_ref {
                name  = env.key
                key = lookup(env.value, "version", "latest")
              }
            }
          }
        }
        dynamic "volume_mounts" {
          for_each = local.cloudrun_secrets_mount[each.key]
          //noinspection HILUnresolvedReference
          content {
            name = "${volume_mounts.key}_secret_volume"
            mount_path = volume_mounts.value.mount_location
          }
        }
      }
      dynamic "volumes"{
        for_each = local.cloudrun_secrets_mount[each.key]
        content {
          name = "${volumes.key}_secret_volume"
          secret {
            secret_name = volumes.key
            items {
              key  = lookup(volumes.value, "version", "latest" )
              path = lookup(volumes.value, "file_name", volumes.key)
            }
          }
        }
      }
    }
    //noinspection HILUnresolvedReference
    dynamic metadata {
      for_each = {metadata: lookup(each.value.template, "metadata",{})}
      content {
        name             = lookup(metadata.value, "name", null)
        annotations      = merge(local.cloudrun_default.template_metadata.annotations, lookup(metadata.value, "annotations", {}))
        labels           = lookup(metadata.value, "labels", null)
        generation       = lookup(metadata.value, "generation", null)
        resource_version = lookup(metadata.value, "resource_version", null)
        self_link        = lookup(metadata.value, "self_link", null)
        uid              = lookup(metadata.value, "uid", null)
        namespace        = lookup(metadata.value, "namespace", null)
      }
    }
  }
  dynamic "traffic" {
    for_each = lookup(local.cloudrun_traffic, each.key, {}) == {} ? local.cloudrun_default.traffic: local.cloudrun_traffic[each.key]
    //noinspection HILUnresolvedReference
    content {
      percent         = traffic.value
      revision_name   = traffic.key == "latest" ? null: traffic.key
      latest_revision = traffic.key == "latest" ? true: false
    }
  }

}

data google_iam_policy noauth {
  for_each = local.cloudrun_specs
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

data google_iam_policy auth {
  //noinspection HILUnresolvedReference
  for_each = local.cloudrun_specs
  dynamic "binding" {
    for_each = local.cloudrun_iam_bindings[each.key]
    content {
      role    = "roles/${binding.key}"
      members = lookup(binding.value, "members", [])
    }
  }
}

//noinspection HILUnresolvedReference
resource google_cloud_run_service_iam_policy self {
  for_each = {
    for key, specs in local.cloudrun_specs : key => specs
      if !specs.auth || (specs.auth && (lookup(local.cloudrun_iam[key], "replace_policy", false)))
  }
  location = google_cloud_run_service.self[each.key].location
  project  = google_cloud_run_service.self[each.key].project
  service  = google_cloud_run_service.self[each.key].name

  policy_data = each.value.auth ? data.google_iam_policy.auth[each.key].policy_data : data.google_iam_policy.noauth[each.key].policy_data
}

//noinspection HILUnresolvedReference
resource google_cloud_run_service_iam_binding self {
  for_each = {
    for key, bindings in local.cloudrun_iam_bindings : key => bindings
    if !lookup(local.cloudrun_iam[key], "replace_policy", false) && length(bindings) != 0
  }
  project  = google_cloud_run_service.self[each.key].project
  location = google_cloud_run_service.self[each.key].location
  members  = lookup(each.value[keys(each.value)[0]], "members", [])
  role     = "roles/${keys(each.value)[0]}"
  service  = google_cloud_run_service.self[each.key].name
}

//noinspection HILUnresolvedReference
resource google_cloud_run_service_iam_member self {
  for_each = {
    for key, specs in local.cloudrun_iam : key => specs
    if local.cloudrun_specs[key].auth && lookup(local.cloudrun_iam[key], "add_member", {}) != {}
  }
  project  = google_cloud_run_service.self[each.key].project
  location = google_cloud_run_service.self[each.key].location
  member   = lookup(each.value.add_member, "member", "")
  role     = "roles/${lookup(each.value.add_member, "role", "")}"
  service  = google_cloud_run_service.self[each.key].name
}

//noinspection HILUnresolvedReference
resource google_cloud_run_domain_mapping self {
  for_each = local.cloudrun_domains
  location = google_cloud_run_service.self[each.key].location
  name     = each.value.domain
  metadata {
    namespace = google_cloud_run_service.self[each.key].project
  }
  spec {
    route_name = google_cloud_run_service.self[each.key].name
  }
}