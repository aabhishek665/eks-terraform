variable "name" {
}
variable "nodegroup_policy_arns" {
  type = list(any)
}
variable "nodegroup_custom_policies" {
  type = any
}
variable "nodegroup_instance_profile_name" {
  type = any
}