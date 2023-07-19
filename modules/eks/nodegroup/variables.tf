variable "cluster_name" {
  type = string
}
variable "create_before_destroy" {
  type        = bool
  default     = false
  description = <<-EOT
    Set true in order to create the new node group before destroying the old one.
    If false, the old node group will be destroyed first, causing downtime.
    Changing this setting will always cause node group to be replaced.
    EOT
}
variable "nodegroup_role_arn" {
  type = string
}
variable "subnet_ids" {
  type = list(any)
}
variable "nodegroups" {
  type    = list(any)
  default = []
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