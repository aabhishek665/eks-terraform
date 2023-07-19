variable "cluster_name" {
  type = string
}
variable "addons" {
  type    = list(any)
  default = []
}
variable "common_tags" {
  type    = map(any)
  default = {}
}
variable "eks_tags" {
  type    = map(any)
  default = {}
}