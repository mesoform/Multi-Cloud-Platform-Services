//noinspection HILUnresolvedReference
resource kubernetes_storage_class self {
  for_each = local.k8s_storage_class
  //noinspection HILUnresolvedReference
  metadata {
    annotations   = lookup(each.value.storage_class.metadata, "annotations", {})
    generate_name = lookup(each.value.storage_class.metadata, "name", null) == null ? lookup(each.value.config_map.metadata, "generate_name", null) : null
    name          = lookup(each.value.storage_class.metadata, "name", null)
    labels        = lookup(each.value.storage_class.metadata, "labels", {})
  }
  parameters = lookup(each.value.storage_class, "parameters", {})
  storage_provisioner = each.value.storage_class.storage_provisioner
#  storage_provisioner = "kubernetes.io/${each.value.storage_class.storage_provisioner}"
  reclaim_policy      = lookup(each.value.storage_class, "reclaim_policy", null )
  volume_binding_mode = lookup(each.value.storage_class, "volume_binding_mode", null )
  allow_volume_expansion = lookup(each.value.storage_class, "allow_volume_expansion", null )
  mount_options = lookup(each.value.storage_class, "mount_options", [] )
  dynamic allowed_topologies {
    for_each = lookup(each.value.storage_class, "allowed_topologies", [] ) != [] ? each.value.storage_class.allowed_topologies : []
#    for_each = lookup(each.value.storage_class, "allowed_topologies", null ) != null ? {allowed_topologies = each.value.storage_class.allowed_topologies } : {}
    content {
      dynamic match_label_expressions {
        for_each = lookup(allowed_topologies.value, "match_label_expressions", null) != null ? {match_label_expressions = allowed_topologies.value.match_label_expressions} : {}
        content {
          key = lookup(match_label_expressions.value, "key", null)
          values = lookup(match_label_expressions.value, "values", null)
        }
      }
    }
  }
}