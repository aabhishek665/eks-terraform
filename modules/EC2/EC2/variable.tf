variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}
variable "vm_count" {
  description = "number of vms to be created"
  type        = number
  default     = 1

}
variable "region" {
  type    = string
  default = ""
}
variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}
variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = ""
}
variable "instance_type" {
  type    = string
  default = ""
}
variable "availability_zone" {
  type    = string
  default = ""
}
variable "ec2_subnet_ids" {
  type = list(string)
}
variable "vpc_security_group_ids" {
  type    = list(string)
  default = null
}
variable "key_name" {
  type    = string
  default = ""
}
variable "iam_instance_profile" {
  type    = string
  default = null
}
variable "associate_public_ip_address" {
  type    = bool
  default = null
}
variable "private_ip" {
  type    = string
  default = null
}
variable "secondary_private_ips" {
  type    = list(string)
  default = null
}
variable "ipv6_address_count" {
  type    = number
  default = null
}
variable "ipv6_addresses" {
  type    = list(string)
  default = null
}
variable "disable_api_termination" {
  type    = bool
  default = null
}
variable "cpu_core_count" {
  type    = number
  default = null
}
variable "cpu_threads_per_core" {
  type    = number
  default = 1
}
variable "enclave_options" {
  type    = list(string)
  default = []
}
variable "credit_specification" {
  type    = list(map(string))
  default = []
}
variable "ebs_block_device" {
  type    = list(any)
  default = []
}
variable "ebs_optimized" {
  type    = bool
  default = null
}
variable "get_password_data" {
  type    = bool
  default = null
}
variable "hibernation" {
  type    = bool
  default = null
}
variable "host_id" {
  type    = string
  default = null
}
variable "capacity_reservation_specification" {
  type    = list(map(string))
  default = []
}
variable "capacity_reservation_target" {
  type    = list(map(string))
  default = []
}
variable "instance_initiated_shutdown_behavior" {
  type    = string
  default = null
}
variable "ephemeral_block_device" {
  type    = list(map(string))
  default = []
}
variable "metadata_options" {
  type    = list(map(string))
  default = []
}
variable "monitoring" {
  type    = bool
  default = null
}
variable "placement_group" {
  type    = string
  default = null
}
variable "root_block_device" {
  type    = list(map(string))
  default = []
}
variable "source_dest_check" {
  type    = bool
  default = true
}
variable "tenancy" {
  type    = string
  default = null
}
variable "user_data_base64" {
  type    = string
  default = null
}
variable "timeouts" {
  type    = map(string)
  default = {}
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "volume_tags" {
  type    = map(string)
  default = {}
}
variable "network_interface" {
  type    = list(map(string))
  default = []
}
variable "inline-remote-exec" {
  type    = list(any)
  default = []
}