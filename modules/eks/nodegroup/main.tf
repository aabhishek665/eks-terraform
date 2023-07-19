
resource "aws_eks_node_group" "nodegroup" {
  count         = length(var.nodegroups)
  cluster_name  = var.cluster_name
  node_role_arn = var.nodegroup_role_arn
  subnet_ids    = var.subnet_ids
  # remote_access {
  #   ec2_ssh_key = lookup(element(var.nodegroups, count.index), "key_name")
  #   source_security_group_ids = lookup(element(var.nodegroups, count.index), "source_security_group_ids")
  # }
  scaling_config {
    desired_size = lookup(lookup(element(var.nodegroups, count.index), "scaling_config"), "desired_size")
    max_size     = lookup(lookup(element(var.nodegroups, count.index), "scaling_config"), "max_size")
    min_size     = lookup(lookup(element(var.nodegroups, count.index), "scaling_config"), "min_size")
  }
  node_group_name = lookup(element(var.nodegroups, count.index), "node_group_name")
  # Optional
  ami_type      = lookup(element(var.nodegroups, count.index), "launch_template") == {} ? lookup(element(var.nodegroups, count.index), "ami_type") : null
  capacity_type = lookup(element(var.nodegroups, count.index), "capacity_type")
  labels        = lookup(element(var.nodegroups, count.index), "kubernetes_labels")
  tags          = lookup(element(var.nodegroups, count.index), "tags")
  disk_size     = lookup(element(var.nodegroups, count.index), "launch_template") == {} ? lookup(element(var.nodegroups, count.index), "disk_size") : null
  #instance_types = lookup(element(var.nodegroups, count.index), "launch_template") == {} ? lookup(element(var.nodegroups, count.index), "instance_types") : null
  #disk_size      = lookup(element(var.nodegroups, count.index), "disk_size")
  instance_types = lookup(element(var.nodegroups, count.index), "instance_types")
  dynamic "launch_template" {
    for_each = lookup(element(var.nodegroups, count.index), "launch_template") != {} ? [lookup(element(var.nodegroups, count.index), "launch_template")] : []
    content {
      id      = lookup(launch_template.value, "launch_template_id")
      version = lookup(launch_template.value, "launch_template_version")
    }
  }
  dynamic "update_config" {
    for_each = lookup(element(var.nodegroups, count.index), "update_config") != {} ? [lookup(element(var.nodegroups, count.index), "update_config")] : []
    content {
      max_unavailable            = lookup(update_config.value, "max_unavailable", null)
      max_unavailable_percentage = lookup(update_config.value, "max_unavailable_percentage", null)
    }
  }
  dynamic "taint" {
    for_each = lookup(element(var.nodegroups, count.index), "taints") != [] ? lookup(element(var.nodegroups, count.index), "taints") : []
    content {
      key    = lookup(taint.value, "key")
      value  = lookup(taint.value, "value")
      effect = lookup(taint.value, "effect")
    }
  }
  # dynamic "timeouts" {
  #   for_each = lookup(element(var.nodegroups,count.index),"timeouts") != {} ? [lookup(element(var.nodegroups,count.index),"timeouts")]:[]
  #   content {
  #     create = lookup(timeouts.value, "create")
  #     update = lookup(timeouts.value, "update")
  #     delete = lookup(timeouts.value, "delete")
  #   }
  # }
  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_eks_addon" "addons" {
  depends_on = [
    aws_eks_node_group.nodegroup
  ]
  count             = length(var.addons) > 0 ? length(var.addons) : 0
  cluster_name      = var.cluster_name
  addon_name        = lookup(element(var.addons, count.index), "addon_name")
  addon_version     = lookup(element(var.addons, count.index), "addon_version")
  resolve_conflicts = "OVERWRITE"
  tags = merge(
    var.common_tags,
    var.eks_tags
  )
}