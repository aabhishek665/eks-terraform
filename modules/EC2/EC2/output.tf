output "id" {
  value = element(concat(aws_instance.instance.*.id, [""]), 0)
}
output "arn" {
  value = element(concat(aws_instance.instance.*.arn, [""]), 0)
}
output "capacity_reservation_specification" {
  value = element(concat(aws_instance.instance.*.capacity_reservation_specification, [""]), 0)
}
output "instance_state" {
  value = element(concat(aws_instance.instance.*.instance_state, [""]), 0)
}
output "primary_network_interface_id" {
  value = element(concat(aws_instance.instance.*.primary_network_interface_id, [""]), 0)
}
output "private_dns" {
  value = element(concat(aws_instance.instance.*.private_dns, [""]), 0)
}
output "public_dns" {
  value = element(concat(aws_instance.instance.*.public_dns, [""]), 0)
}
output "public_ip" {
  value = element(concat(aws_instance.instance.*.public_ip, [""]), 0)
}
output "tags_all" {
  value = element(concat(aws_instance.instance.*.tags_all, [""]), 0)
}
output "outpost_arn" {
  value = element(concat(aws_instance.instance.*.outpost_arn, [""]), 0)
}
# output "private_ip" {
#    value = element(concat(aws_instance.instance.*.private_ip, [""]), 0)
# }

output "private_ip" {
  value = aws_instance.instance.*.private_ip
}