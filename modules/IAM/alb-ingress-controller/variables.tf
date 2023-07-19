variable "name" {
  type = string
}
variable "alb_controller_policy_arns" {
  type = list(any)
}
variable "alb_controller_custom_policies" {
  type = any
}
variable "alb_controller-trust-policy" {
  type = any
}