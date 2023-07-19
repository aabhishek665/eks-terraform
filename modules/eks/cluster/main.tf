resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  role_arn                  = var.eks_cluster_role_arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnets
    security_group_ids      = var.cluster_security_group_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
  dynamic "encryption_config" {
    for_each = toset(var.cluster_encryption_config)

    content {
      provider {
        key_arn = encryption_config.value["provider_key_arn"]
      }
      resources = encryption_config.value["resources"]
    }
  }
  tags = merge(
    var.common_tags,
    var.eks_tags
  )
}
resource "aws_eks_addon" "addons" {
  count             = length(var.addons) > 0 ? length(var.addons) : 0
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = lookup(element(var.addons, count.index), "addon_name")
  addon_version     = lookup(element(var.addons, count.index), "addon_version")
  resolve_conflicts = "OVERWRITE"
  tags = merge(
    var.common_tags,
    var.eks_tags
  )
}
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}
resource "aws_iam_openid_connect_provider" "default" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
  tags = merge(
    var.common_tags,
    var.eks_tags
  )
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
}
