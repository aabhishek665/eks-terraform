output "template_id" {
  value = aws_launch_template.launch_template.id
}
output "template_arn" {
  value = aws_launch_template.launch_template.arn
}
output "template_version" {
  value = aws_launch_template.launch_template.latest_version
}
