//noinspection HILUnresolvedReference
resource "kubernetes_ingress_v1" "self" {
  for_each = local.k8s_ingress
  wait_for_load_balancer = lookup(each.value.ingress, "wait_for_load_balancer", false)
  //noinspection HILUnresolvedReference
  metadata {
    name          = lookup(each.value.ingress.metadata, "name", null)
    generate_name = lookup(each.value.ingress.metadata, "name", null) == null ? lookup(each.value.service.metadata, "generate_name", null) : null
    labels        = lookup(each.value.ingress.metadata, "labels", {})
    namespace = lookup(each.value.ingress.metadata, "namespace", null)
    annotations   = lookup(each.value.ingress.metadata, "annotations", {})
  }
  spec {
    ingress_class_name = lookup(each.value.ingress.spec, "ingress_class_name", null)
    //noinspection HILUnresolvedReference
    dynamic "default_backend" {
      for_each = lookup(each.value.ingress.spec, "default_backend", null) != null ? {default_backend : each.value.ingress.spec.default_backend} : {}
      content{
        //noinspection HILUnresolvedReference
        dynamic resource {
          for_each = lookup(default_backend.value, "resource", null) != null ? {resource : default_backend.value.resource} : {}
          content {
            kind = lookup(resource.value, "kind", null)
            name = lookup(resource.value, "name", null)
            api_group = lookup(resource.value, "api_group", null)
          }
        }
        //noinspection HILUnresolvedReference
        dynamic service {
          for_each = lookup(default_backend.value, "service", null) != null ? {service : default_backend.value.service} : {}
          content {
            name = lookup(service.value, "name", null)
            dynamic port {
              for_each = lookup(service.value, "port", null) != null ? {port: service.value.port} : {}
              content {
                name = lookup(port.value, "name", null)
                number = lookup(port.value, "number", null)
              }
            }
          }
        }
      }
    }

    //noinspection HILUnresolvedReference
    dynamic "rule" {
      for_each = lookup(each.value.ingress.spec, "rule", null) != null ? {rule : each.value.ingress.spec.rule} : {}
      content {
        # host = lookup(each.value.ingress.spec.rule, "host", {})
        host = lookup(rule.value, "host", {})
        http{
          //noinspection HILUnresolvedReference
          dynamic "path" {
            for_each = lookup(rule.value.http, "paths")
            content {
              path = path.value.path
              path_type = lookup(path.value, "path_type", null)
              backend {
                //noinspection HILUnresolvedReference
                dynamic resource {
                  for_each = lookup(path.value.backend, "resource", null) != null ? {resource : path.value.backend.resource} : {}
                  content {
                    kind = lookup(resource.value, "kind", null)
                    name = lookup(resource.value, "name", null)
                    api_group = lookup(resource.value, "api_group", null)
                  }
                }
                //noinspection HILUnresolvedReference
                dynamic service {
                  for_each = lookup(path.value.backend, "service", null) != null ? {service : path.value.backende.service} : {}
                  content {
                    name = lookup(service.value, "name", null)
                    dynamic port {
                      for_each = lookup(service.value, "port", null) != null ? {port: service.value.port} : {}
                      content {
                        name = lookup(port.value, "name", null)
                        number = lookup(port.value, "number", null)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }


    //noinspection HILUnresolvedReference
    dynamic tls{
      for_each = lookup(each.value.ingress.spec, "tls", null) != null ? {tls : each.value.ingress.spec.tls} : {}
      content {
        hosts = lookup(tls.value, "hosts", [])
        secret_name = lookup(tls.value, "secret_name", null)
      }
    }
  }
}
