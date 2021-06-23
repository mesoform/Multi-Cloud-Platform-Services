resource "google_compute_instance_group_manager" "default" {
  for_each           = var.zones
  base_instance_name = var.base_instance_name
  name               = "${var.name}-${each.value}"
  description        = var.description
  zone               = "${var.region}-${each.value}"
  target_size        = var.target_size
  project            = var.project
  version {
    name              = var.version_name == null ? formatdate("YYYYMMDDhhmm", timestamp()) : var.version_name
    instance_template = var.instance_template[each.value]
  }
  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policies
    content {
      health_check      = auto_healing_policies.value.health_check
      initial_delay_sec = auto_healing_policies.value.initial_delay_sec
    }
  }
  dynamic "stateful_disk" {
    for_each = var.stateful_disks
    content {
      device_name = stateful_disk.value.device_name[each.value]
      delete_rule = lookup(stateful_disk.value, "delete_rule", null)

    }
  }

  dynamic "update_policy" {
    for_each = var.update_policy
    content {
      instance_redistribution_type = lookup(update_policy.value, "instance_redistribution_type", null)
      max_surge_fixed              = lookup(update_policy.value, "max_surge_fixed", null)
      max_surge_percent            = lookup(update_policy.value, "max_surge_percent", null)
      max_unavailable_fixed        = lookup(update_policy.value, "max_unavailable_fixed", null)
      max_unavailable_percent      = lookup(update_policy.value, "max_unavailable_percent", null)
      min_ready_sec                = lookup(update_policy.value, "min_ready_sec", null)
      minimal_action               = update_policy.value.minimal_action
//      type                         = "testing"
      type                         = update_policy.value.type
    }
  }
  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value["name"]
      port = named_port.value["port"]
    }
  }
}