resource "aws_iam_role" "bastion-host-role" {
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
resource "aws_iam_role_policy_attachment" "bastion-policy-attachments" {
  count      = length(var.bastion_policy_arns)
  policy_arn = element(var.bastion_policy_arns, count.index)
  role       = aws_iam_role.bastion-host-role.name
}
resource "aws_iam_policy" "BastionCustomPolicy" {
  count       = var.bastion_custom_policies != {} ? 1 : 0
  name        = "${var.name}-custom-policy"
  description = "${var.name}-custom-policy"
  policy      = jsonencode(var.bastion_custom_policies)
}
resource "aws_iam_role_policy_attachment" "bastion-Custom-policy-attachment" {
  count      = var.bastion_custom_policies != {} ? 1 : 0
  role       = aws_iam_role.bastion-host-role.name
  policy_arn = aws_iam_policy.BastionCustomPolicy.0.arn
}
resource "aws_iam_instance_profile" "bastion-instanceprofile" {
  name = var.bastion_instance_profile_name
  role = aws_iam_role.bastion-host-role.name
}