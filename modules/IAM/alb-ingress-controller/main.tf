resource "aws_iam_role" "eks_alb_controller_role" {
  name               = var.name
  assume_role_policy = jsonencode(var.alb_controller-trust-policy)
}

data "aws_iam_policy" "alb_controller_policies" {
  count = length(var.alb_controller_policy_arns)
  arn   = element(var.alb_controller_policy_arns, count.index)
}
resource "aws_iam_role_policy_attachment" "alb_controller-policy-attachments" {
  count      = length(data.aws_iam_policy.alb_controller_policies.*)
  policy_arn = data.aws_iam_policy.alb_controller_policies[count.index].arn
  role       = aws_iam_role.eks_alb_controller_role.name
}
resource "aws_iam_policy" "alb_controller_custom_policy" {
  count       = var.alb_controller_custom_policies != {} ? 1 : 0
  name        = "${var.name}-custom-policy"
  description = "${var.name}-custom-policy"
  policy      = jsonencode(var.alb_controller_custom_policies)
}
resource "aws_iam_role_policy_attachment" "alb_controller-Custom-policy-attachment" {
  count      = var.alb_controller_custom_policies != {} ? 1 : 0
  role       = aws_iam_role.eks_alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_custom_policy.0.arn
}