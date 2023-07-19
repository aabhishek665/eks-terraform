variable "name" {
  type        = string
  description = "Security group name"
}
variable "description" {
  type        = string
  description = "Security group description"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "common_tags" {
  type    = map(any)
  default = {}
}
variable "sg_tags" {
  type    = map(any)
  default = {}
}