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

output "cloudrun_project_id" {
  value = local.cloudrun.project_id
}

output "cloudrun_location_id" {
  value = local.cloudrun.location_id
}

output "cloudrun_services" {
  value = values(local.cloudrun_specs).*.name
}
