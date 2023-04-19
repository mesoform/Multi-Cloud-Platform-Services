resource "kubernetes_horizontal_pod_autoscaler_v1" "self" {
  for_each = local.k8s_pod_autoscaler

  metadata {
    annotations   = lookup(each.value.pod_autoscaler.metadata, "annotations", {})
    generate_name = lookup(each.value.pod_autoscaler.metadata, "name", null) == null ? lookup(each.value.config_map.metadata, "generate_name", null) : null
    name          = lookup(each.value.pod_autoscaler.metadata, "name", null)
    labels        = lookup(each.value.pod_autoscaler.metadata, "labels", {})
    namespace     = lookup(each.value.pod_autoscaler.metadata, "namespace", null)
  }
  spec {
    max_replicas                      = lookup(each.value.pod_autoscaler.spec, "max_replicas", null)
    min_replicas                      = lookup(each.value.pod_autoscaler.spec, "min_replicas", null)
    target_cpu_utilization_percentage = lookup(each.value.pod_autoscaler.spec, "target_cpu_utilization_percentage", null)
    dynamic "scale_target_ref" {
      for_each = lookup(each.value.pod_autoscaler.spec, "scale_target_ref", null) == null ? {} : { scale_target_ref : each.value.pod_autoscaler.spec.scale_target_ref }
      content {
        api_version = lookup(scale_target_ref.value, "api_version", null)
        kind        = lookup(scale_target_ref.value, "kind", null)
        name        = lookup(scale_target_ref.value, "name", null)
      }
    }
  }
}
