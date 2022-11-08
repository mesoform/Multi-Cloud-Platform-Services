output gae {
  value = local.gae
}

output gae_flex {
  value = local.as_flex_specs
}

output gae_std {
  value = local.as_std_specs
}

output cloudrun {
  value = local.cloudrun
}

output cloudrun_service_ids {
  value = [
    for service in google_cloud_run_service.self:
          service.id
  ]
}
