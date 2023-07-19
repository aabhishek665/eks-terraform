resource "aws_iam_role" "eks_cluster_role" {
  name = var.name

  assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Principal": {
        "Service": "eks.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
    }
]
}
POLICY
}

data "aws_iam_policy" "EKSPolicies" {
  count = length(var.eks_policy_arns)
  arn   = element(var.eks_policy_arns, count.index)
}
resource "aws_iam_role_policy_attachment" "eks-cluster-policy-attachments" {
  count      = length(data.aws_iam_policy.EKSPolicies.*)
  policy_arn = data.aws_iam_policy.EKSPolicies[count.index].arn
  role       = aws_iam_role.eks_cluster_role.name
}
resource "aws_iam_policy" "EKSCustomPolicy" {
  count       = var.eks_custom_policies != {} ? 1 : 0
  name        = "${var.name}-custom-policy"
  description = "${var.name}-custom-policy"
  policy      = jsonencode(var.eks_custom_policies)
}
resource "aws_iam_role_policy_attachment" "EB-Custom-policy-attachment" {
  count      = var.eks_custom_policies != {} ? 1 : 0
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.EKSCustomPolicy.0.arn
}