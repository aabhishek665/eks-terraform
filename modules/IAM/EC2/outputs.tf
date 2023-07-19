output "name" {
  value = aws_iam_role.bastion-host-role.name
}
output "arn" {
  value = aws_iam_role.bastion-host-role.arn
}
output "profile_arn" {
  value = aws_iam_instance_profile.bastion-instanceprofile.arn
}
output "profile_name" {
  value = aws_iam_instance_profile.bastion-instanceprofile.name
}