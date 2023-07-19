output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}
output "cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}
output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.default.arn
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}