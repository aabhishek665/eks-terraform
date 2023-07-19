variable "name" {
  description = "Name to associate with the launch template"
}
variable "monitoring" {
  description = "The monitoring option for the instance"
  default     = null
  type        = map(any)
}
variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}
variable "elastic_gpu_specifications" {
  description = "Elastic GPU to attach to the instances"
  type        = map(any)
  default     = null
}
variable "disable_api_termination" {
  type        = bool
  description = "If `true`, enables EC2 Instance Termination Protection with api call"
  default     = false
}
variable "shutdown_behavior" {
  description = "Shutdown behavior for the instance. Can be stop or terminate"
  default     = "stop"
}
variable "description" {
  #description = "launch template for autoscaling and for eks"
  default = ""
}
variable "credit_specification" {
  description = "Customize the credit specification of the instances"
  type        = map(any)
  default     = null
}
variable "cpu_options" {
  description = "Customize the cpi  cores of the instances"
  type        = map(any)
  default     = null
}
variable "capacity_reservation_specification" {
  description = "Indicates the instance's Capacity Reservation preferences"
  default     = null
  type        = map(any)
}
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "image_id" {
  description = "image id"
  default     = "ami-0a23ccb2cdd9286bb"
}
variable "key_name" {
  description = "key name"
  default     = null
}
variable "associate_public_ip_address" {
  description = "boolean"
  default     = false
}

variable "iam_instance_profile" {
  description = "Name of IAM instance profile associated with launched instances"
  default     = null
  type        = map(any)
}

variable "vpc_security_group_ids" {
  description = "List of security group names to attach"
  default     = []
}
variable "placement" {
  description = "The placement of the instance"
  type        = map(any)
  default     = null
}
variable "block_device_mappings" {
  type        = list(any)
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  default     = []
}
variable "network_interfaces" {
  type        = list(any)
  description = "Customize network interfaces to be attached at instance boot time"
  default     = []
}
variable "hibernation_options" {
  type        = map(any)
  default     = null
  description = "If set to true, the launched EC2 instance will hibernation enabled."
}
variable "ram_disk_id" {
  type        = string
  default     = null
  description = "The ID of the RAM disk"
}
variable "kernel_id" {
  type        = string
  default     = null
  description = "The kernel ID."
}
variable "enclave_options" {
  type        = map(any)
  description = "If set to true, Nitro Enclaves will be enabled on the instance."
  default     = null
}
variable "license_specification" {
  type        = map(any)
  default     = null
  description = "A list of license specifications to associate with. "
}
variable "metadata_options" {
  type        = map(any)
  default     = null
  description = "Customize the metadata options for the instance"
}
variable "tags" {
  type    = map(any)
  default = {}
}
variable "user_data" {

}

