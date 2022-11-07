output "gae" {
  value = local.gae
}

output "gae_flex" {
  value = local.as_flex_specs
}

output "gae_std" {
  value = local.as_std_specs
}

output "cloudrun" {
  value = local.cloudrun
}

output "cloudrun_services" {
  value = google_cloud_run_service.self[*].name
}

output "cloudrun_location_id" {
  value = google_cloud_run_service.self[*].location
}
