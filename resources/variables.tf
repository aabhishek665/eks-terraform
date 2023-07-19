variable "AccountId" {
  type = string
}
variable "region" {
  type        = string
  description = "Provide region"
  default     = "ap-south-1"
}
variable "environment" {
  description = "Environment value dev/test/stage/prod"
  type        = string
  default     = "dev"
}
variable "prefix" {
  type    = string
  default = ""
}
variable "eksSubnets" {
  description = "EKS Subnets"
  type        = list(any)
  default     = []
}
variable "application_subnets" {
  description = "Nodegroup Subnets"
  type        = list(any)
  default     = []
}
variable "vpc_id" {
  type    = string
  default = ""
}

variable "eks_tags" {
  type    = map(any)
  default = {}
}
variable "common_tags" {
  type    = map(any)
  default = {}
}
variable "sg_tags" {
  type    = map(any)
  default = {}
}
variable "cluster_name" {
  type = string
}
variable "eks_cluster_role_arn" {
  type    = string
  default = ""
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster."
}
variable "eks_subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}
variable "enabled_cluster_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = list(any)
  default     = []
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}
variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}
variable "nodegroups" {
  type    = list(any)
  default = []
}
variable "eks_policy_arns" {
  type = list(any)
}
variable "nodegroup_policy_arns" {
  type = list(any)
}
variable "eks_custom_policies" {
  type = any
}
variable "nodegroup_custom_policies" {
  type = any
}
variable "addons" {
  type = list(any)
}
variable "ami_id" {
  type = string
}
variable "addons_post_nodegroup" {
  type = list(any)
}
variable "nodegroup_instance_profile_name" {
  type = any
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
variable "bastion_key_pair" {
  type = string
}
variable "configmap_users" {
  type = any
}
variable "alb_ingress_role_name" {
  type = string
}
variable "bastion_ami" {
  type = string
}
variable "ec2_subnet" {
  type = list(string)
}
variable "alb_ingress_controller_policy_arns" {
  type = any
}
variable "alb_ingress_controller_custom_policies" {
  type = any
}
variable "created_by" {
  type = string
}