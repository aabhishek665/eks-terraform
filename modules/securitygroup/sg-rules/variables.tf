variable "ingress_with_cidr_blocks" {
  type    = list(any)
  default = []
}
variable "egress_with_cidr_blocks" {
  type    = list(any)
  default = []
}
variable "ingress_with_sgid" {
  type    = list(any)
  default = []
}
variable "egress_with_sgid" {
  type    = list(any)
  default = []
}
variable "security_group_id" {
  type = string
}