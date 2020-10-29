data external test_map_config {
  query = {
    for key, value in local.k8s_services :
    key => keys(value)[0]
  }
  program = ["python", "${path.module}/test_map_config.py"]
}

output test_map_config {
  value = data.external.test_map_config.result
}

data external test_config_map_data {
  query   = local.k8s_config_map_data["resources"]
  program = ["python", "${path.module}/test_config_map_data.py"]
}

output test_config_map_data {
  value = data.external.test_config_map_data.result
}

data external test_config_map_binary_data {
  query   = local.k8s_config_map_binary_data["resources"]
  program = ["python", "${path.module}/test_config_map_binary_data.py"]
}

output test_config_map_binary_data {
  value = data.external.test_config_map_binary_data.result
}

data external test_secret_data {
  query   = local.k8s_secret_data["resources"]
  program = ["python", "${path.module}/test_secret_data.py"]
}

output test_secret_data {
  value = data.external.test_secret_data.result
}

data external test_kubernetes_deployment {
  //query   = lookup(local.k8s_deployments.mosquitto.deployment.metadata, "labels", {})
  query   = lookup(local.k8s_deployments.resources.deployment.spec.selector, "match_labels", {})
  program = ["/usr/local/bin/python3", "${path.module}/test_deployment.py"]
}
output test_deployment {
  value = data.external.test_kubernetes_deployment.result
}

data external test_pod {
  query   = lookup(local.k8s_pods["resources"].pod.spec, "env", {})
  program = ["/usr/local/bin/python3", "${path.module}/test_pod.py"]
}
output test_pod {
  value = data.external.test_pod.result
}

data external test_ingress {
  query   = lookup(local.k8s_ingress["resources"].ingress.spec, "backend", {})
  program = ["/usr/local/bin/python3", "${path.module}/test_ingress.py"]
}
output test_ingress {
  value = data.external.test_ingress.result
}

data external test_pod_autoscaler {
  query   = lookup(local.k8s_pod_autoscaler["resources"].pod_autoscaler.spec, "scale_target_ref", {})
  program = ["/usr/local/bin/python3", "${path.module}/test_pod_autoscaler.py"]
}
output test_pod_autoscaler {
  value = data.external.test_pod_autoscaler.result
}

data external test_service {
  query   = lookup(local.k8s_services["resources"].service.spec, "selector", {})
  program = ["/usr/local/bin/python3", "${path.module}/test_service.py"]
}
output test_service {
  value = data.external.test_service.result
}

data external test_secret {
  query   = local.k8s_secret["resources"].secret.data
  program = ["/usr/local/bin/python3", "${path.module}/test_secret.py"]
}
output test_secret {
  value = data.external.test_secret.result
}