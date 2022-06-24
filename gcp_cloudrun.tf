
//noinspection HILUnresolvedReference
data "google_project" "default" {
  count      = local.cloudrun == {} || lookup(local.cloudrun, "create_google_project", false) ? 0 : 1
  project_id = local.cloudrun["project_id"]
}

resource "google_project_service" "iam" {
  count              = local.cloudrun == {} ? 0 : 1
  project            = lookup(local.cloudrun, "create_google_project", false) ? google_project.default[0].project_id : data.google_project.default[0].project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_reg" {
  count                      = lookup(local.cloudrun, "create_artifact_registry", false) ? 1 : 0
  project                    = lookup(local.cloudrun, "create_google_project", false) ? google_project.default[0].project_id : data.google_project.default[0].project_id
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudrun" {
  count              = local.cloudrun == {} ? 0 : 1
  project            = lookup(local.cloudrun, "create_google_project", false) ? google_project.default[0].project_id : data.google_project.default[0].project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
  disable_dependent_services = false
}

resource "google_project_service" "secret_manager" {
  for_each = nonsensitive(local.secret_projects)
  service = "secretmanager.googleapis.com"
  project = each.value
  disable_on_destroy = false
}

//noinspection HILUnresolvedReference
data "google_secret_manager_secret" "self" {
  provider = google-beta
  for_each = nonsensitive(local.cloudrun_secrets_existing)
  secret_id = each.key
  project = lookup(each.value, "project", null) == null ? local.cloudrun["project_id"] : each.value.project
}

//noinspection HILUnresolvedReference,ConflictingProperties
resource "google_project" "default" {
  count           = local.cloudrun != {} && lookup(local.cloudrun, "create_google_project", false) ? 1 : 0
  name            = lookup(local.cloudrun, "project_name", local.cloudrun.project_id)
  project_id      = lookup(local.cloudrun, "project_id", local.cloudrun.project_id)
  org_id          = lookup(local.cloudrun, "organization_name", null)
  folder_id       = lookup(local.cloudrun, "folder_id", null) == null ? null : local.gae.folder_id
  labels          = merge(lookup(local.project, "labels", {}), lookup(local.gae, "project_labels", {}))
  billing_account = lookup(local.cloudrun, "billing_account", null)
}

//noinspection HILUnresolvedReference
resource "google_artifact_registry_repository" "self" {
  count         = lookup(local.cloudrun, "create_artifact_registry", false) ? 1 : 0
  provider      = google-beta
  project       = google_project_service.artifact_reg[0].project
  location      = local.cloudrun.location_id
  format        = "DOCKER"
  repository_id = lookup(local.cloudrun, "repository_id", "cloudrun-repo")
}

//noinspection HILUnresolvedReference
resource "google_cloud_run_service" "self" {
  depends_on = [google_secret_manager_secret_version.self]
  provider = google-beta
  for_each = local.cloudrun_specs
  location = local.cloudrun.location_id
  name     = each.value.name
  project  = google_project_service.cloudrun[0].project
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
          for_each = lookup(each.value.template.containers, "resources", {})
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

data "google_iam_policy" "noauth" {
  for_each = local.cloudrun_specs
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

data "google_iam_policy" "auth" {
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
resource "google_cloud_run_service_iam_policy" "self" {
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
resource "google_cloud_run_service_iam_binding" "self" {
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
resource "google_cloud_run_service_iam_member" "self" {
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
resource "google_secret_manager_secret" "self" {
  provider = google-beta
  depends_on = [google_project_service.secret_manager]
  for_each = nonsensitive(local.cloudrun_secrets_create)
  secret_id = each.key
  project = lookup(each.value, "project", null) == null ? lookup(local.cloudrun, "create_google_project", false) ? google_project.default[0].project_id : data.google_project.default[0].project_id : each.value.project
  labels = lookup(each.value, "labels", null )
  expire_time = lookup(each.value, "expire_time", null )
  ttl = lookup(each.value, "ttl", null )
  replication {
    automatic = !lookup(each.value, "replicas", false) #If "replias" is present automatic should be false
    //noinspection HILUnresolvedReference
    dynamic user_managed {
      for_each = lookup(each.value, "replicas", false) ? each.value.replicas : {}
      content {
        //noinspection HILUnresolvedReference
        replicas {
          location = lookup(user_managed.value, "location", local.cloudrun.location_id )
          dynamic customer_managed_encryption {
            for_each = lookup(user_managed.value, "kms_key_name", {} )
            content {
              kms_key_name = customer_managed_encryption.value
            }
          }
        }
      }
    }
  }
  //noinspection HILUnresolvedReference
  dynamic topics {
    for_each = lookup(each.value, "topic", null) == null ? {} : {for topic in each.value.topics: topic => {name = topic}}
    //noinspection HILUnresolvedReference
    content {
      name = topics.value.name
    }
  }
  //noinspection HILUnresolvedReference
  dynamic "rotation" {
    for_each = lookup(each.value, "rotation", null) == null ? {} : {rotation = each.value.rotation}
    content {
      next_rotation_time = lookup(rotation.value, "next_rotation_time", null)
      rotation_period = lookup(rotation.value, "rotation_period", null)
    }
  }
}

//noinspection HILUnresolvedReference
resource "google_secret_manager_secret_version" "self" {
  provider = google-beta
  for_each = nonsensitive(merge(local.cloudrun_secrets_create, local.cloudrun_secrets_existing))
  secret = try(google_secret_manager_secret.self[each.key].id, data.google_secret_manager_secret.self[each.key].id)
  secret_data = local.cloudrun_secrets[each.key].secret_data
}

//noinspection HILUnresolvedReference
resource "google_cloud_run_domain_mapping" "self" {
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


