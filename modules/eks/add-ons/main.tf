resource "aws_eks_addon" "addons" {
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