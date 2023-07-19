variable "name" {
}
variable "bastion_policy_arns" {
  type = list(any)
}
variable "bastion_custom_policies" {
  type = any
}
variable "bastion_instance_profile_name" {
  type = any
}