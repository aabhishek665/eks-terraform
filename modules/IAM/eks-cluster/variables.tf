variable "name" {
  type = string
}
variable "eks_policy_arns" {
  type = list(any)
}
variable "eks_custom_policies" {
  type = any
}