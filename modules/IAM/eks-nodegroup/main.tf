resource "aws_iam_role" "eks-nodegroup-role" {
  name = var.name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "nodegroup-policy-attachments" {
  count      = length(var.nodegroup_policy_arns)
  policy_arn = element(var.nodegroup_policy_arns, count.index)
  role       = aws_iam_role.eks-nodegroup-role.name
}
resource "aws_iam_policy" "NodegroupCustomPolicy" {
  count       = var.nodegroup_custom_policies != {} ? 1 : 0
  name        = "${var.name}-custom-policy"
  description = "${var.name}-custom-policy"
  policy      = jsonencode(var.nodegroup_custom_policies)
}
resource "aws_iam_role_policy_attachment" "Nodegroup-Custom-policy-attachment" {
  count      = var.nodegroup_custom_policies != {} ? 1 : 0
  role       = aws_iam_role.eks-nodegroup-role.name
  policy_arn = aws_iam_policy.NodegroupCustomPolicy.0.arn
}
resource "aws_iam_instance_profile" "nodegroup-instanceprofile" {
  name = var.nodegroup_instance_profile_name
  role = aws_iam_role.eks-nodegroup-role.name
}