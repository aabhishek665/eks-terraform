output "eks_nodegroup_role_arn" {
  value = aws_iam_role.eks-nodegroup-role.arn
}
output "eks_nodegroup_instance_profile" {
  value = aws_iam_instance_profile.nodegroup-instanceprofile.arn
}