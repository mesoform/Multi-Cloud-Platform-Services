data external test_policy_members{
  query = {
    for role, members in local.cloudrun_iam_bindings["app1"]:
      role => length(lookup(members, "members", []))
  }

  program = ["python", "${path.module}/test_policy_members.py"]
}
output test_policy_members {
  value = data.external.test_policy_members.result
}

data external test_ae_traffic_extended {
  query = lookup(local.cloudrun_traffic, "app1-service", {})
  program = ["python", "${path.module}/test_cloudrun_traffic_extended.py"]
}
output test_ae_traffic_1 {
  value = data.external.test_ae_traffic_extended.result
}

data external test_ae_traffic {
  query = lookup(local.cloudrun_traffic, "app1", {})
  program = ["python", "${path.module}/test_cloudrun_traffic.py"]
}

output test_ae_traffic {
  value = data.external.test_ae_traffic.result
}
data external test_ae_traffic_empty {
  query = lookup(local.cloudrun_traffic, "app2", {})
  program = ["python", "${path.module}/test_cloudrun_traffic.py"]
}

output test_ae_traffic_empty {
  value = data.external.test_ae_traffic.result
}

data external test_secret_env {
  query = {
    for secret, config in local.cloudrun_secrets_env["app1"]:
      secret => lookup(config, "env_name", null)
  }
  program = ["python", "${path.module}/test_cloudrun_secret_env.py"]
}

output test_secret_env {
  value = data.external.test_secret_env.result
}

data external test_secret_mount {
  query = {
    for secret, config in local.cloudrun_secrets_mount["app1"]:
      secret => lookup(config, "mount_location", null)
  }
  program = ["python", "${path.module}/test_cloudrun_secret_mount.py"]
}

output test_secret_mount {
  value = data.external.test_secret_mount.result
}

data external test_secret {
  query = {
    for secret, config in local.cloudrun_secrets:
      secret => lookup(config, "secret_data", null )
  }
  program = ["python", "${path.module}/test_cloudrun_secret.py"]
}

output test_secret {
  value = data.external.test_secret.result
}

data external test_domain {
  query = {
    for service, config in local.cloudrun_domains:
      service => lookup(config, "domain", null )
  }
  program = ["python", "${path.module}/test_cloudrun_secret.py"]
}

output test_domain {
  value = data.external.test_secret.result
}