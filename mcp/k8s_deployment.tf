provider "kubernetes" {
  load_config_file = true
}

resource "kubernetes_deployment" "self" {
  for_each         = local.k8s_deployments
  wait_for_rollout = lookup(each.value.deployment, "wait_for_rollout", true)
  metadata {
    annotations   = lookup(each.value.deployment.metadata, "annotations", {})
    generate_name = lookup(each.value.deployment.metadata, "name", null) == null ? lookup(each.value.deployment.metadata, "generate_name", null) : null
    name          = lookup(each.value.deployment.metadata, "name", null)
    labels        = lookup(each.value.deployment.metadata, "labels", {})
    namespace     = lookup(each.value.deployment.metadata, "namespace", null)
  }
  spec {
    min_ready_seconds         = lookup(each.value.deployment.spec, "min_ready_seconds", null)
    paused                    = lookup(each.value.deployment.spec, "paused", null)
    progress_deadline_seconds = lookup(each.value.deployment.spec, "progress_deadline_seconds", null)
    replicas                  = lookup(each.value.deployment.spec, "replicas", null)
    revision_history_limit    = lookup(each.value.deployment.spec, "revision_history_limit", null)
    dynamic "strategy" {
      for_each = lookup(each.value.deployment.spec, "strategy", null) == null ? {} : { strategy : each.value.deployment.spec.strategy }
      content {
        type = lookup(strategy.value, "type", null)
        dynamic "rolling_update" {
          for_each = lookup(strategy.value, "rolling_update", null) == null ? {} : { rolling_update : strategy.value.rolling_update }
          content {
            max_surge       = strategy.value.rolling_update.max_surge
            max_unavailable = strategy.value.rolling_update.max_unavailable
          }
        }
      }
    }
    dynamic "selector" {
      for_each = lookup(each.value.deployment.spec, "selector", null) == null ? {} : { selector : each.value.deployment.spec.selector }
      content {
        match_labels = lookup(selector.value, "match_labels", null)
      }
    }

    template {
      metadata {
        labels = lookup(each.value.deployment.spec.template.metadata, "labels", {})
      }
      spec {
        active_deadline_seconds         = lookup(each.value.deployment.spec.template.spec, "active_deadline_seconds", null)
        automount_service_account_token = lookup(each.value.deployment.spec.template.spec, "automount_service_account_token", null)
        dns_policy                      = lookup(each.value.deployment.spec.template.spec, "dns_policy", null)
        host_ipc                        = lookup(each.value.deployment.spec.template.spec, "host_ipc", null)
        host_network                    = lookup(each.value.deployment.spec.template.spec, "host_network", null)
        host_pid                        = lookup(each.value.deployment.spec.template.spec, "host_pid", null)
        hostname                        = lookup(each.value.deployment.spec.template.spec, "hostname", null)
        node_name                       = lookup(each.value.deployment.spec.template.spec, "node_name", null)
        node_selector                   = lookup(each.value.deployment.spec.template.spec, "node_selector", null)
        priority_class_name             = lookup(each.value.deployment.spec.template.spec, "priority_class_name", null)
        restart_policy                  = lookup(each.value.deployment.spec.template.spec, "restart_policy", null)
        //security_context                = lookup(each.value.deployment.spec.template.spec, "security_context", null)
        service_account_name             = lookup(each.value.deployment.spec.template.spec, "service_account_name", null)
        share_process_namespace          = lookup(each.value.deployment.spec.template.spec, "share_process_namespace", null)
        subdomain                        = lookup(each.value.deployment.spec.template.spec, "subdomain", null)
        termination_grace_period_seconds = lookup(each.value.deployment.spec.template.spec, "termination_grace_period_seconds", null)

        dynamic "volume" {
          //for_each = lookup(each.value.deployment.spec.template.spec, "volume", null) == null ? [] : [for volume in lookup(each.value.deployment.spec.template.spec, "volume", null) : {
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          // If you use this expression to test for the existence of a given field, terraform issues the TERRAFORM CRASH
          // This message occurs when values of different types are described in the content block.
          // If all the values of the content block are of the same type, no error occurs.
          for_each = [for volume in lookup(each.value.deployment.spec.template.spec, "volume", null) : {
            name                    = lookup(volume, "name", null)
            azure_disk              = lookup(volume, "azure_disk", null)
            azure_file              = lookup(volume, "azure_file", null)
            ceph_fs                 = lookup(volume, "ceph_fs", null)
            cinder                  = lookup(volume, "cinder", null)
            config_map              = lookup(volume, "config_map", null)
            downward_api            = lookup(volume, "downward_api", null)
            empty_dir               = lookup(volume, "empty_dir", null)
            fc                      = lookup(volume, "fc", null)
            flex_volume             = lookup(volume, "flex_volume", null)
            flocker                 = lookup(volume, "flocker", null)
            gce_persistent_disk     = lookup(volume, "gce_persistent_disk", null)
            git_repo                = lookup(volume, "git_repo", null)
            glusterfs               = lookup(volume, "glusterfs", null)
            host_path               = lookup(volume, "host_path", null)
            iscsi                   = lookup(volume, "iscsi", null)
            nfs                     = lookup(volume, "nfs", null)
            persistent_volume_claim = lookup(volume, "persistent_volume_claim", null)
            photon_persistent_disk  = lookup(volume, "photon_persistent_disk", null)
            projected               = lookup(volume, "projected", null)
            quobyte                 = lookup(volume, "quobyte", null)
            rbd                     = lookup(volume, "rbd", null)
            secret                  = lookup(volume, "secret", null)
            vsphere_volume          = lookup(volume, "vsphere_volume", null)
          }]
          content {
            name = lookup(volume.value, "name", null)
            dynamic "aws_elastic_block_store" {
              for_each = lookup(volume.value, "aws_elastic_block_store", null) == null ? {} : { aws_elastic_block_store : volume.value.aws_elastic_block_store }
              content {
                fs_type   = lookup(aws_elastic_block_store.value, "fs_type", null)
                partition = lookup(aws_elastic_block_store.value, "partition", null)
                read_only = lookup(aws_elastic_block_store.value, "read_only", null)
                volume_id = lookup(aws_elastic_block_store.value, "volume_id", null)
              }
            }
            dynamic "azure_disk" {
              for_each = lookup(volume.value, "azure_disk", null) == null ? {} : { azure_disk : volume.value.azure_disk }
              content {
                caching_mode  = lookup(azure_disk.value, "caching_mode", null)
                data_disk_uri = lookup(azure_disk.value, "data_disk_uri", null)
                disk_name     = lookup(azure_disk.value, "disk_name", null)
                fs_type       = lookup(azure_disk.value, "fs_type", null)
                read_only     = lookup(azure_disk.value, "read_only", null)
              }
            }
            dynamic "azure_file" {
              for_each = lookup(volume.value, "azure_file", null) == null ? {} : { azure_file : volume.value.azure_file }
              content {
                read_only   = lookup(azure_file.value, "read_only", null)
                secret_name = lookup(azure_file.value, "secret_name", null)
                share_name  = lookup(azure_file.value, "share_name", null)
              }
            }
            dynamic "ceph_fs" {
              for_each = lookup(volume.value, "ceph_fs", null) == null ? {} : { ceph_fs : volume.value.ceph_fs }
              content {
                monitors    = lookup(ceph_fs.value, "monitors", null)
                path        = lookup(ceph_fs.value, "path", null)
                read_only   = lookup(ceph_fs.value, "read_only", null)
                secret_file = lookup(ceph_fs.value, "secret_file", null)
                user        = lookup(ceph_fs.value, "user", null)
                dynamic "secret_ref" {
                  for_each = lookup(ceph_fs.value, "secret_ref", null) == null ? {} : { secret_ref : ceph_fs.value.secret_ref }
                  content {
                    name      = lookup(secret_ref.value, "name", null)
                    namespace = lookup(secret_ref.value, "namespace", null)
                  }
                }
              }
            }
            dynamic "cinder" {
              for_each = lookup(volume.value, "cinder", null) == null ? {} : { cinder : volume.value.cinder }
              content {
                fs_type   = lookup(cinder.value, "fs_type", null)
                read_only = lookup(cinder.value, "read_only", null)
                volume_id = lookup(cinder.value, "volume_id", null)
              }
            }
            dynamic "config_map" {
              for_each = lookup(volume.value, "config_map", null) == null ? {} : { config_map : volume.value.config_map }
              content {
                default_mode = lookup(config_map.value, "default_mode", null)
                optional     = lookup(config_map.value, "optional", null)
                name         = lookup(config_map.value, "name", null)
                dynamic "items" {
                  for_each = lookup(config_map.value, "items", null) == null ? {} : { items : config_map.value.items }
                  content {
                    key  = lookup(items.value, "key", null)
                    mode = lookup(items.value, "mode", null)
                    path = lookup(items.value, "path", null)

                  }
                }
              }
            }
            dynamic "downward_api" {
              for_each = lookup(volume.value, "downward_api", null) == null ? {} : { downward_api : volume.value.downward_api }
              content {
                default_mode = lookup(downward_api.value, "default_mode", null)
                //  dynamic "items" { // incorrect description in the documentation of 'items'
                //  for_each = lookup(downward_api.value, "items", null) == null ? {} : { items : downward_api.value.items }
                //  content {
                //  dynamic "field_ref" {
                //  for_each = lookup(items.value, "field_ref", null) == null ? {} : { field_ref : items.value.field_ref }
                //  content {
                //  api_version = lookup(field_ref.value, "api_version", null)
                //  field_path  = lookup(field_ref.value, "field_path", null)
                //  }
                //  }
                //    mode = lookup(items.value, "mode", null)
                //  path = lookup(items.value, "path", null)

                //  }
                //}
              }
            }
            dynamic "empty_dir" {
              for_each = lookup(volume.value, "empty_dir", null) == null ? {} : { empty_dir : volume.value.empty_dir }
              content {
                medium     = lookup(empty_dir.value, "medium", null)
                size_limit = lookup(empty_dir.value, "size_limit", null)
              }
            }
            dynamic "fc" {
              for_each = lookup(volume.value, "fc", null) == null ? {} : { fc : volume.value.fc }
              content {
                fs_type      = lookup(fc.value, "fs_type", null)
                lun          = lookup(fc.value, "lun", null)
                read_only    = lookup(fc.value, "read_only", null)
                target_ww_ns = lookup(fc.value, "target_ww_ns", null)
              }
            }
            dynamic "flex_volume" {
              for_each = lookup(volume.value, "flex_volume", null) == null ? {} : { flex_volume : volume.value.flex_volume }
              content {
                driver    = lookup(flex_volume.value, "driver", null)
                fs_type   = lookup(flex_volume.value, "fs_type", null)
                options   = lookup(flex_volume.value, "options", null)
                read_only = lookup(flex_volume.value, "read_only", null)
                dynamic "secret_ref" {
                  for_each = lookup(flex_volume.value, "secret_ref", null) == null ? {} : { secret_ref : flex_volume.value.secret_ref }
                  content {
                    name = lookup(secret_ref.value, "name", null)
                    //optional = lookup(secret_ref.value, "optional", null) //described in documentation
                  }
                }
              }
            }
            dynamic "flocker" {
              for_each = lookup(volume.value, "flocker", null) == null ? {} : { flocker : volume.value.flocker }
              content {
                dataset_name = lookup(flocker.value, "dataset_name", null)
                dataset_uuid = lookup(flocker.value, "dataset_uuid", null)
              }
            }
            dynamic "gce_persistent_disk" {
              for_each = lookup(volume.value, "gce_persistent_disk", null) == null ? {} : { gce_persistent_disk : volume.value.gce_persistent_disk }
              content {
                fs_type   = lookup(gce_persistent_disk.value, "fs_type", null)
                partition = lookup(gce_persistent_disk.value, "partition", null)
                pd_name   = lookup(gce_persistent_disk.value, "pd_name", null)
                read_only = lookup(gce_persistent_disk.value, "read_only", null)
              }
            }
            dynamic "git_repo" {
              for_each = lookup(volume.value, "git_repo", null) == null ? {} : { git_repo : volume.value.git_repo }
              content {
                directory  = lookup(git_repo.value, "directory", null)
                repository = lookup(git_repo.value, "repository", null)
                revision   = lookup(git_repo.value, "revision", null)
              }
            }
            dynamic "glusterfs" {
              for_each = lookup(volume.value, "glusterfs", null) == null ? {} : { glusterfs : volume.value.glusterfs }
              content {
                endpoints_name = lookup(glusterfs.value, "endpoints_name", null)
                path           = lookup(glusterfs.value, "path", null)
                read_only      = lookup(glusterfs.value, "read_only", null)
              }
            }
            dynamic "host_path" {
              for_each = lookup(volume.value, "host_path", null) == null ? {} : { host_path : volume.value.host_path }
              content {
                path = lookup(host_path.value, "path", null)
                type = lookup(host_path.value, "type", null)
              }
            }
            dynamic "iscsi" {
              for_each = lookup(volume.value, "iscsi", null) == null ? {} : { iscsi : volume.value.iscsi }
              content {
                fs_type         = lookup(iscsi.value, "fs_type", null)
                iqn             = lookup(iscsi.value, "iqn", null)
                iscsi_interface = lookup(iscsi.value, "iscsi_interface", null)
                lun             = lookup(iscsi.value, "lun", null)
                read_only       = lookup(iscsi.value, "read_only", null)
                target_portal   = lookup(iscsi.value, "target_portal", null)
              }
            }
            dynamic "nfs" {
              for_each = lookup(volume.value, "nfs", null) == null ? {} : { nfs : volume.value.nfs }
              content {
                path      = lookup(nfs.value, "path", null)
                read_only = lookup(nfs.value, "read_only", null)
                server    = lookup(nfs.value, "server", null)
              }
            }
            dynamic "persistent_volume_claim" {
              for_each = lookup(volume.value, "persistent_volume_claim", null) == null ? {} : { persistent_volume_claim : volume.value.persistent_volume_claim }
              content {
                claim_name = lookup(persistent_volume_claim.value, "claim_name", null)
                read_only  = lookup(persistent_volume_claim.value, "read_only", null)
              }
            }
            dynamic "photon_persistent_disk" {
              for_each = lookup(volume.value, "photon_persistent_disk", null) == null ? {} : { photon_persistent_disk : volume.value.photon_persistent_disk }
              content {
                fs_type = lookup(photon_persistent_disk.value, "fs_type", null)
                pd_id   = lookup(photon_persistent_disk.value, "pd_id", null)
              }
            }
            dynamic "projected" {
              for_each = lookup(volume.value, "projected", null) == null ? {} : { projected : volume.value.projected }
              content {
                default_mode = lookup(projected.value, "default_mode", null)
                dynamic "sources" {
                  for_each = lookup(projected.value, "sources", null) == null ? {} : { sources : projected.value.sources }
                  content {
                    dynamic "config_map" {
                      for_each = lookup(sources.value, "config_map", null) == null ? {} : { config_map : sources.value.config_map }
                      content {
                        //default_mode = lookup(config_map.value, "default_mode", null) //described in documentation
                        optional = lookup(config_map.value, "optional", null)
                        name     = lookup(config_map.value, "name", null)
                        dynamic "items" {
                          for_each = lookup(config_map.value, "items", null) == null ? {} : { items : config_map.value.items }
                          content {
                            key  = lookup(items.value, "key", null)
                            mode = lookup(items.value, "mode", null)
                            path = lookup(items.value, "path", null)
                          }
                        }
                      }
                    }

                    dynamic "downward_api" {
                      for_each = lookup(sources.value, "downward_api", null) == null ? {} : { downward_api : sources.value.downward_api }
                      content {
                        //default_mode = lookup(downward_api.value, "default_mode", null) //described in documentation
                        dynamic "items" {
                          for_each = lookup(downward_api.value, "items", null) == null ? {} : { items : downward_api.value.items }
                          content {
                            //key  = lookup(items.value, "key", null) //described in documentation
                            mode = lookup(items.value, "mode", null)
                            path = lookup(items.value, "path", null)
                          }
                        }
                      }
                    }
                    dynamic "secret" {
                      for_each = lookup(sources.value, "secret", null) == null ? {} : { secret : sources.value.secret }
                      content {
                        //default_mode = lookup(secret.value, "default_mode", null) //described in documentation
                        optional = lookup(secret.value, "optional", null)
                        //secret_name  = lookup(secret.value, "secret_name", null) //described in documentation
                        dynamic "items" {
                          for_each = lookup(secret.value, "items", null) == null ? {} : { items : secret.value.items }
                          content {
                            key  = lookup(items.value, "key", null)
                            mode = lookup(items.value, "mode", null)
                            path = lookup(items.value, "path", null)
                          }
                        }
                      }
                    }
                    dynamic "service_account_token" {
                      for_each = lookup(sources.value, "service_account_token", null) == null ? {} : { service_account_token : sources.value.service_account_token }
                      content {
                        audience           = lookup(service_account_token.value, "audience", null)
                        expiration_seconds = lookup(service_account_token.value, "expiration_seconds", null)
                        path               = lookup(service_account_token.value, "path", null)
                      }
                    }
                  }
                }
              }
            }
            dynamic "quobyte" {
              for_each = lookup(volume.value, "quobyte", null) == null ? {} : { quobyte : volume.value.quobyte }
              content {
                group     = lookup(quobyte.value, "group", null)
                read_only = lookup(quobyte.value, "read_only", null)
                registry  = lookup(quobyte.value, "registry", null)
                user      = lookup(quobyte.value, "user", null)
                volume    = lookup(quobyte.value, "volume", null)
              }
            }
            dynamic "rbd" {
              for_each = lookup(volume.value, "rbd", null) == null ? {} : { rbd : volume.value.rbd }
              content {
                ceph_monitors = lookup(rbd.value, "ceph_monitors", null)
                fs_type       = lookup(rbd.value, "fs_type", null)
                keyring       = lookup(rbd.value, "keyring", null)
                rados_user    = lookup(rbd.value, "rados_user", null)
                rbd_image     = lookup(rbd.value, "rbd_image", null)
                rbd_pool      = lookup(rbd.value, "rbd_pool", null)
                read_only     = lookup(rbd.value, "read_only", null)
                dynamic "secret_ref" {
                  for_each = lookup(rbd.value, "secret_ref", null) == null ? {} : { secret_ref : rbd.value.secret_ref }
                  content {
                    name      = lookup(secret_ref.value, "name", null)
                    namespace = lookup(secret_ref.value, "namespace", null) // not described in documentation
                    //optional = lookup(secret_ref.value, "optional", null) //described in documentation
                  }
                }
              }
            }
            dynamic "secret" {
              for_each = lookup(volume.value, "secret", null) == null ? {} : { secret : volume.value.secret }
              content {
                default_mode = lookup(secret.value, "default_mode", null) //described in documentation
                optional     = lookup(secret.value, "optional", null)
                secret_name  = lookup(secret.value, "secret_name", null) //described in documentation
                dynamic "items" {
                  for_each = lookup(secret.value, "items", null) == null ? {} : { items : secret.value.items }
                  content {
                    key  = lookup(items.value, "key", null)
                    mode = lookup(items.value, "mode", null)
                    path = lookup(items.value, "path", null)
                  }
                }
              }
            }
            dynamic "vsphere_volume" {
              for_each = lookup(volume.value, "vsphere_volume", null) == null ? {} : { vsphere_volume : volume.value.vsphere_volume }
              content {
                fs_type     = lookup(vsphere_volume.value, "fs_type", null)
                volume_path = lookup(vsphere_volume.value, "volume_path", null)
              }
            }
          }
        }
        dynamic "toleration" {
          for_each = lookup(each.value.deployment.spec.template.spec, "toleration", null) == null ? {} : { toleration : each.value.deployment.spec.template.spec.toleration }
          content {
            effect             = lookup(toleration.value, "effect", null)
            key                = lookup(toleration.value, "key", null)
            operator           = lookup(toleration.value, "operator", null)
            toleration_seconds = lookup(toleration.value, "toleration_seconds", null)
            value              = lookup(toleration.value, "value", null)
          }
        }
        dynamic "image_pull_secrets" {
          for_each = lookup(each.value.deployment.spec.template.spec, "image_pull_secrets", null) == null ? {} : { image_pull_secrets : each.value.deployment.spec.template.spec.image_pull_secrets }
          content {
            name = lookup(image_pull_secrets.value, "name", null)
          }
        }
        dynamic "dns_config" {
          for_each = lookup(each.value.deployment.spec.template.spec, "dns_config", null) == null ? {} : { dns_config : each.value.deployment.spec.template.spec.dns_config }
          content {
            nameservers = lookup(dns_config.value, "nameservers", null)
            searches    = lookup(dns_config.value, "searches", null)
            dynamic "option" {
              for_each = lookup(dns_config.value, "option", null) == null ? {} : { option : dns_config.value.option }
              content {
                name  = option.value.name
                value = lookup(option.value, "value", null)
              }
            }
          }
        }
        dynamic "host_aliases" {
          for_each = lookup(each.value.deployment.spec.template.spec, "host_aliases", null) == null ? {} : { host_aliases : each.value.deployment.spec.template.spec.host_aliases }
          content {
            hostnames = lookup(host_aliases.value, "hostnames", null)
            ip        = lookup(host_aliases.value, "ip", null)
          }
        }
        dynamic "init_container" {
          for_each = lookup(each.value.deployment.spec.template.spec, "init_container", null) == null ? {} : { init_container : each.value.deployment.spec.template.spec.init_container }
          content {
            name    = lookup(init_container.value, "name", null)
            image   = lookup(init_container.value, "image", null)
            command = lookup(init_container.value, "command", null)
          }
        }
        dynamic "affinity" {
          for_each = lookup(each.value.deployment.spec.template.spec, "affinity", null) == null ? {} : { affinity : each.value.deployment.spec.template.spec.affinity }
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  match_expressions {
                    key      = affinity.value.node_affinity.required_during_scheduling_ignored_during_execution.node_selector_term.match_expressions.key
                    operator = affinity.value.node_affinity.required_during_scheduling_ignored_during_execution.node_selector_term.match_expressions.operator
                    values   = lookup(affinity.value.node_affinity.required_during_scheduling_ignored_during_execution.node_selector_term.match_expressions, "values", null)
                  }
                }
              }
            }
          }
        }
        dynamic "container" {
          //for_each = lookup(each.value.deployment.spec.template.spec, "container", null) == null ? {} : { container : each.value.deployment.spec.template.spec.container }
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          // If you use this expression to test for the existence of a given field, terraform issues the TERRAFORM CRASH
          // This message occurs when values of different types are described in the content block.
          // If all the values of the content block are of the same type, no error occurs.
          for_each = [for container in lookup(each.value.deployment.spec.template.spec, "container", null) : {
            image             = lookup(container, "image", null)
            name              = lookup(container, "name", null)
            args              = lookup(container, "args", null)
            command           = lookup(container, "command", null)
            image_pull_policy = lookup(container, "image_pull_policy", null)
            //security_context  = lookup(container, "security_context", null)
            //startup_probe = lookup(container, "startup_probe", null)
            stdin                    = lookup(container, "stdin", null)
            stdin_once               = lookup(container, "stdin_once", null)
            termination_message_path = lookup(container, "termination_message_path", null)
            tty                      = lookup(container, "tty", null)
            working_dir              = lookup(container, "working_dir", null)
            env                      = lookup(container, "env", null)
            env_from                 = lookup(container, "env_from", null)
            lifecycle                = lookup(container, "lifecycle", null)
            port                     = lookup(container, "port", null)
            resources                = lookup(container, "resources", null)
            liveness_probe           = lookup(container, "liveness_probe", null)
            readiness_probe          = lookup(container, "readiness_probe", null)
            volume_mount             = lookup(container, "volume_mount", null)

          }]
          content {
            image             = lookup(container.value, "image", null)
            name              = lookup(container.value, "name", null)
            args              = lookup(container.value, "args", null)
            command           = lookup(container.value, "command", null)
            image_pull_policy = lookup(container.value, "image_pull_policy", null)
            //security_context  = lookup(container.value, "security_context", null)
            //startup_probe = lookup(container.value, "startup_probe", null)
            stdin                    = lookup(container.value, "stdin", null)
            stdin_once               = lookup(container.value, "stdin_once", null)
            termination_message_path = lookup(container.value, "termination_message_path", null)
            tty                      = lookup(container.value, "tty", null)
            working_dir              = lookup(container.value, "working_dir", null)

            dynamic "env" {
              for_each = lookup(container.value, "env", null) == null ? {} : { env : container.value.env }
              content {
                name  = env.value.name
                value = env.value.value
                dynamic "value_from" {
                  for_each = lookup(env.value, "value_from", null) == null ? {} : { value_from : env.value.value_from }
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = lookup(value_from.value, "config_map_key_ref", null) == null ? {} : { config_map_key_ref : value_from.value.config_map_key_ref }
                      content {
                        key      = lookup(config_map_key_ref.value, "key", null)
                        name     = lookup(config_map_key_ref.value, "name", null)
                        optional = lookup(config_map_key_ref.value, "optional", null)
                      }
                    }
                    dynamic "field_ref" {
                      for_each = lookup(value_from.value, "field_ref", null) == null ? {} : { field_ref : value_from.value.field_ref }
                      content {
                        api_version = lookup(field_ref.value, "api_version", null)
                        field_path  = lookup(field_ref.value, "field_path", null)
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = lookup(value_from.value, "resource_fielf_ref", null) == null ? {} : { resource_field_ref : value_from.value.resource_field_ref }
                      content {
                        container_name = lookup(resource_field_ref.value, "container_name", null)
                        resource       = lookup(resource_field_ref.value, "resource", null)
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = lookup(value_from.value, "secret_key_ref", null) == null ? {} : { secret_key_ref : value_from.value.secret_key_ref }
                      content {
                        key      = lookup(secret_key_ref.value, "key", null)
                        name     = lookup(secret_key_ref.value, "name", null)
                        optional = lookup(secret_key_ref.value, "optional", null)
                      }
                    }
                  }
                }
              }
            }
            dynamic "env_from" {
              for_each = lookup(container.value, "env_from", null) == null ? {} : { env_from : container.value.env_from }
              content {
                dynamic "config_map_ref" {
                  for_each = lookup(env_from.value, "config_map_ref", null) == null ? {} : { config_map_ref : env_from.value.config_map_ref }
                  content {
                    name     = lookup(config_map_ref.value, "name", null)
                    optional = lookup(config_map_ref.value, "optional", null)
                  }
                }
                prefix = lookup(env_from.value, "prefix", null)
                dynamic "secret_ref" {
                  for_each = lookup(env_from.value, "secret_ref", null) == null ? {} : { secret_ref : env_from.value.secret_ref }
                  content {
                    name     = lookup(secret_ref.value, "name", null)
                    optional = lookup(secret_ref.value, "optional", null)
                  }
                }
              }
            }
            dynamic "lifecycle" {
              for_each = lookup(container.value, "lifecycle", null) == null ? {} : { lifecycle : container.value.lifecycle }
              content {
                dynamic "post_start" {
                  for_each = lookup(lifecycle.value, "post_start", null) == null ? {} : { post_start : lifecycle.value.post_start }
                  content {
                    dynamic "exec" {
                      for_each = lookup(post_start.value, "exec", null) == null ? {} : { exec : post_start.value.exec }
                      content {
                        command = exec.value.command
                      }
                    }
                    dynamic "http_get" {
                      for_each = lookup(post_start.value, "http_get", null) == null ? {} : { http_get : post_start.value.http_get }
                      content {
                        host   = lookup(http_get.value, "host", null)
                        path   = lookup(http_get.value, "path", null)
                        scheme = lookup(http_get.value, "scheme", null)
                        port   = http_get.value.port
                        dynamic "http_header" {
                          for_each = lookup(http_get.value, "http_header", null) == null ? {} : { http_header : http_get.value.http_header }
                          content {
                            name  = http_header.value.name
                            value = http_header.value.value
                          }
                        }
                      }
                    }
                    dynamic "tcp_socket" {
                      for_each = lookup(post_start.value, "tcp_socket", null) == null ? {} : { tcp_socket : post_start.value.tcp_socket }
                      content {
                        port = tcp_socket.value.port
                      }
                    }
                  }
                }
                dynamic "pre_stop" {
                  for_each = lookup(lifecycle.value, "pre_stop", null) == null ? {} : { pre_stop : lifecycle.value.pre_stop }
                  content {
                    dynamic "exec" {
                      for_each = lookup(pre_stop.value, "exec", null) == null ? {} : { exec : pre_stop.value.exec }
                      content {
                        command = exec.value.command
                      }
                    }
                    dynamic "http_get" {
                      for_each = lookup(pre_stop.value, "http_get", null) == null ? {} : { http_get : pre_stop.value.http_get }
                      content {
                        host   = lookup(http_get.value, "host", null)
                        path   = lookup(http_get.value, "path", null)
                        scheme = lookup(http_get.value, "scheme", null)
                        port   = lookup(http_get.value, "port", null)
                        dynamic "http_header" {
                          for_each = lookup(http_get.value, "http_header", null) == null ? {} : { http_header : http_get.value.http_header }
                          content {
                            name  = http_header.value.name
                            value = http_header.value.value
                          }
                        }
                      }
                    }
                    dynamic "tcp_socket" {
                      for_each = lookup(pre_stop.value, "tcp_socket", null) == null ? {} : { tcp_socket : pre_stop.value.tcp_socket }
                      content {
                        port = tcp_socket.value.port
                      }
                    }
                  }
                }
              }
            }
            dynamic "port" {
              for_each = lookup(container.value, "port", null) == null ? {} : { port : container.value.port }
              content {
                container_port = port.value.container_port
                host_ip        = lookup(port.value, "host_ip", null)
                host_port      = lookup(port.value, "host_port", null)
                name           = lookup(port.value, "name", null)
                protocol       = lookup(port.value, "protocol", null)
              }
            }
            dynamic "resources" {
              for_each = lookup(container.value, "resources", null) == null ? {} : { resources : container.value.resources }
              content {
                dynamic "limits" {
                  for_each = lookup(resources.value, "limits", null) == null ? {} : { limits : resources.value.limits }
                  content {
                    cpu    = lookup(limits.value, "cpu", null)
                    memory = lookup(limits.value, "memory", null)
                  }
                }
                dynamic "requests" {
                  for_each = lookup(resources.value, "requests", null) == null ? {} : { requests : resources.value.requests }
                  content {
                    cpu    = lookup(requests.value, "cpu", null)
                    memory = lookup(requests.value, "memory", null)
                  }
                }
              }
            }
            dynamic "liveness_probe" {
              for_each = lookup(container.value, "liveness_probe", null) == null ? {} : { liveness_probe : container.value.liveness_probe }
              content {
                initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
                period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
                timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)
                success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
                failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)
                dynamic "http_get" {
                  for_each = lookup(liveness_probe.value, "http_get", null) == null ? {} : { http_get : liveness_probe.value.http_get }
                  content {
                    host   = lookup(http_get.value, "host", null)
                    path   = lookup(http_get.value, "path", null)
                    scheme = lookup(http_get.value, "scheme", null)
                    port   = lookup(http_get.value, "port", null)
                    dynamic "http_header" {
                      for_each = lookup(http_get.value, "http_header", null) == null ? {} : { http_header : http_get.value.http_header }
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = lookup(liveness_probe.value, "tcp_socket", null) == null ? {} : { tcp_socket : liveness_probe.value.tcp_socket }
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = lookup(liveness_probe.value, "exec", null) == null ? {} : { exec : liveness_probe.value.exec }
                  content {
                    command = exec.value.command
                  }
                }
              }
            }
            dynamic "readiness_probe" {
              for_each = lookup(container.value, "readiness_probe", null) == null ? {} : { readiness_probe : container.value.readiness_probe }
              content {
                initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
                period_seconds        = lookup(readiness_probe.value, "period_seconds", null)
                timeout_seconds       = lookup(readiness_probe.value, "timeout_seconds", null)
                success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
                failure_threshold     = lookup(readiness_probe.value, "failure_threshold", null)
                dynamic "http_get" {
                  for_each = lookup(readiness_probe.value, "http_get", null) == null ? {} : { http_get : readiness_probe.value.http_get }
                  content {
                    host   = lookup(http_get.value, "host", null)
                    path   = lookup(http_get.value, "path", null)
                    scheme = lookup(http_get.value, "scheme", null)
                    port   = lookup(http_get.value, "port", null)
                    dynamic "http_header" {
                      for_each = lookup(http_get.value, "http_header", null) == null ? {} : { http_header : http_get.value.http_header }
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = lookup(readiness_probe.value, "tcp_socket", null) == null ? {} : { tcp_socket : readiness_probe.value.tcp_socket }
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = lookup(readiness_probe.value, "exec", null) == null ? {} : { exec : readiness_probe.value.exec }
                  content {
                    command = exec.value.command
                  }
                }
              }
            }
            dynamic "volume_mount" {
              for_each = lookup(container.value, "volume_mount", null) == null ? [] : [for volume_mount in lookup(container.value, "volume_mount", null) : {
                // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                // If you use this expression to test for the existence of a given field, terraform issues the TERRAFORM CRASH
                // This message occurs when values of different types are described in the content block.
                // If all the values of the content block are of the same type, no error occurs.
                mount_path        = lookup(volume_mount, "mount_path", null)
                name              = lookup(volume_mount, "name", null)
                read_only         = lookup(volume_mount, "read_only", null)
                sub_path          = lookup(volume_mount, "sub_path", null)
                mount_propagation = lookup(volume_mount, "mount_propagation", null)
              }]
              content {
                mount_path        = lookup(volume_mount.value, "mount_path", null)
                name              = lookup(volume_mount.value, "name", null)
                read_only         = lookup(volume_mount.value, "read_only", null)
                sub_path          = lookup(volume_mount.value, "sub_path", null)
                mount_propagation = lookup(volume_mount.value, "mount_propagation", null)

              }
            }
          }
        }
      }
    }
  }
}
