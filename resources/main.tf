provider "aws" {
  region  = var.region
  profile = "mfa"
}

######################## EKS CLUSTER SECURITY GROUP ########################
module "eks_cluster_securitygroup" {
  source      = "../modules/securitygroup/sg-main"
  name        = "${var.prefix}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
  sg_tags = {
    "Name" = "${var.prefix}-eks-cluster-sg"
  }
}
module "eks_cluster_securitygroup_rules" {
  depends_on = [
    module.eks_cluster_securitygroup,
    module.eks_nodes_securitygroup,
    module.eks_bastion_securitygroup
  ]
  source            = "../modules/securitygroup/sg-rules"
  security_group_id = module.eks_cluster_securitygroup.securitygroup_id
  ingress_with_sgid = [
    ({
      "description"              = "Allow worker nodes to communicate with the cluster API Server"
      "from_port"                = 0
      "to_port"                  = 0
      "protocol"                 = "-1"
      "source_security_group_id" = module.eks_cluster_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow worker nodes to communicate with the cluster API Server"
      "from_port"                = 443
      "to_port"                  = 443
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_nodes_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow inbound traffic from bastion"
      "from_port"                = 443
      "to_port"                  = 443
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_bastion_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow SSH from bastion to the nodes"
      "from_port"                = 22
      "to_port"                  = 22
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_bastion_securitygroup.securitygroup_id
    })
  ]
  egress_with_cidr_blocks = [
    ({
      "description" = "Allow all outbound communication"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
      "cidr_blocks" = ["0.0.0.0/0"]
    })
  ]
}

######################## EKS NODE GROUP SECURITY GROUP ########################
module "eks_nodes_securitygroup" {
  source      = "../modules/securitygroup/sg-main"
  name        = "${var.prefix}-node-group-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
  sg_tags = {
    "Name" = "${var.prefix}-node-group-sg"
  }
}
module "eks_nodes_securitygroup_rules" {
  depends_on = [
    module.eks_nodes_securitygroup,
    module.eks_cluster_securitygroup
  ]
  source            = "../modules/securitygroup/sg-rules"
  security_group_id = module.eks_nodes_securitygroup.securitygroup_id
  ingress_with_sgid = [
    ({
      "description"              = "Allow nodes to communicate with each other"
      "from_port"                = 0
      "to_port"                  = 65535
      "protocol"                 = "-1"
      "source_security_group_id" = module.eks_nodes_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
      "from_port"                = 1025
      "to_port"                  = 65535
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_cluster_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow pods to communicate with the cluster API Server"
      "from_port"                = 443
      "to_port"                  = 443
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_cluster_securitygroup.securitygroup_id
    }),
    ({
      "description"              = "Allow cluster control to receive communication from the worker Kubelets"
      "from_port"                = 443
      "to_port"                  = 443
      "protocol"                 = "tcp"
      "source_security_group_id" = module.eks_nodes_securitygroup.securitygroup_id
    })
  ]
  egress_with_cidr_blocks = [
    ({
      "description" = "Allow all outbound communication"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
      "cidr_blocks" = ["0.0.0.0/0"]
    })
  ]
}

######################## EKS CLUSTER IAM ROLE ########################
module "eks_cluster_role" {
  source              = "../modules/IAM/eks-cluster"
  name                = "${var.prefix}-cluster-role"
  eks_policy_arns     = var.eks_policy_arns
  eks_custom_policies = var.eks_custom_policies
}

######################## EKS NODEGROUP IAM ROLE ########################
module "eks_nodegroup_role" {
  source                          = "../modules/IAM/eks-nodegroup"
  name                            = "${var.prefix}-nodegroup-role"
  nodegroup_policy_arns           = var.nodegroup_policy_arns
  nodegroup_custom_policies       = var.nodegroup_custom_policies
  nodegroup_instance_profile_name = var.nodegroup_instance_profile_name
}

######################## EKS CLUSTER ########################
module "eks" {
  source = "../modules/eks/cluster"
  depends_on = [
    module.eks_cluster_role,
    module.eks_cluster_securitygroup
  ]
  cluster_name                    = var.cluster_name
  eks_cluster_role_arn            = module.eks_cluster_role.eks_cluster_arn
  kubernetes_version              = var.kubernetes_version
  subnets                         = var.eks_subnets
  addons                          = var.addons
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_security_group_ids      = [module.eks_cluster_securitygroup.securitygroup_id]
  enabled_cluster_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  eks_tags = {
    "Name" = var.cluster_name
  }
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
}

######################## LAUNCH TEMPLATE RESOURCES ########################
data "aws_security_groups" "cluster" {
  depends_on = [
    module.eks
  ]
  filter {
    name   = "group-name"
    values = ["eks-cluster-sg-${var.cluster_name}-*"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_eks_cluster" "eks_cluster" {
  depends_on = [
    module.eks
  ]
  name = module.eks.cluster_id
}

locals {
  k8s_cluster_ip = cidrhost(data.aws_eks_cluster.eks_cluster.kubernetes_network_config[0]["service_ipv4_cidr"], 10)
  nodegroups = {
    for x in var.nodegroups :
    format("%s", x.node_group_name) => x
  }
  eks_user_data_test = <<USERDATA
  MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=${data.aws_eks_cluster.eks_cluster.certificate_authority[0].data}
API_SERVER_URL=${data.aws_eks_cluster.eks_cluster.endpoint}
K8S_CLUSTER_DNS_IP=${local.k8s_cluster_ip}
/etc/eks/bootstrap.sh ${data.aws_eks_cluster.eks_cluster.name} --kubelet-extra-args '--max-pods=1000' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false
systemctl start docker
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true
--//--
  USERDATA
}

######################## LAUNCH TEMPLATE ########################
module "launchtemplate" {
  source                 = "../modules/EC2/launchtemplate"
  for_each               = local.nodegroups
  name                   = "${each.value.node_group_name}-launchtemplate"
  image_id               = var.ami_id
  instance_type          = null
  key_name               = each.value.keyname
  vpc_security_group_ids = data.aws_security_groups.cluster.ids
  user_data              = local.eks_user_data_test
  block_device_mappings = [({
    "device_name"           = "/dev/xvda"
    "no_device"             = 0
    "volume_size"           = each.value.disk_size
    "volume_type"           = "gp2"
    "delete_on_termination" = "true"
    "encrypted"             = "true"
    "iops"                  = null
    "kms_key_id"            = null
    "snapshot_id"           = null
    "throughput"            = null
  })]
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "Name"                                          = each.value.node_group_name
    "environment"                                   = var.environment
    "region"                                        = var.region
    "account"                                       = var.AccountId
    "Created-By"                                    = var.created_by
  }
  shutdown_behavior = "terminate"
}

######################## EKS NODEGROUP RESOURCES ########################
locals {
  node_groups_details = [for index, nodegroup in local.nodegroups : {
    scaling_config            = lookup(nodegroup, "scaling_config")
    ami_type                  = lookup(nodegroup, "ami_type")
    capacity_type             = lookup(nodegroup, "capacity_type")
    instance_types            = lookup(nodegroup, "instance_types")
    disk_size                 = lookup(nodegroup, "disk_size")
    key_name                  = lookup(nodegroup, "keyname")
    source_security_group_ids = data.aws_security_groups.cluster.ids
    launch_template = {
      "launch_template_id"      = module.launchtemplate[index].template_id
      "launch_template_version" = module.launchtemplate[index].template_version
    }
    tags = {
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
      "Name"                                          = lookup(nodegroup, "node_group_name")
      "environment"                                   = var.environment
      "region"                                        = var.region
      "account"                                       = var.AccountId
      "Created-By"                                    = var.created_by
    }
    kubernetes_labels = lookup(nodegroup, "kubernetes_labels")
    update_config     = lookup(nodegroup, "update_config")
    taints            = lookup(nodegroup, "taints")
    timeouts          = lookup(nodegroup, "timeouts")
    node_group_name   = lookup(nodegroup, "node_group_name")
    }
  ]
}
data "aws_eks_cluster" "cluster" {
  depends_on = [
    module.eks
  ]
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  depends_on = [
    module.eks
  ]
  name = module.eks.cluster_id
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

######################## EKS NODE GROUP ########################
module "eks-nodegroup" {
  source = "../modules/eks/nodegroup"
  depends_on = [
    module.eks,
    module.launchtemplate,
    module.eks_nodegroup_role
  ]
  for_each           = local.nodegroups
  cluster_name       = var.cluster_name
  nodegroup_role_arn = module.eks_nodegroup_role.eks_nodegroup_role_arn
  subnet_ids         = var.application_subnets
  eks_tags = {
    "Name" = var.cluster_name
  }
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
  nodegroups = [{
    scaling_config            = each.value.scaling_config
    ami_type                  = each.value.ami_type
    capacity_type             = each.value.capacity_type
    instance_types            = each.value.instance_types
    source_security_group_ids = data.aws_security_groups.cluster.ids
    launch_template = {
      "launch_template_id"      = module.launchtemplate[each.value.node_group_name].template_id
      "launch_template_version" = module.launchtemplate[each.value.node_group_name].template_version
    }
    tags = {
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
      "Name"                                          = each.value.node_group_name
      "environment"                                   = var.environment
      "region"                                        = var.region
      "account"                                       = var.AccountId
      "Created-By"                                    = var.created_by
    }
    kubernetes_labels = each.value.kubernetes_labels
    update_config     = each.value.update_config
    taints            = each.value.taints
    timeouts          = each.value.timeouts
    node_group_name   = each.value.node_group_name
  }]
}

######################## EKS ADD-ONS WHICH ARE CREATED AFTER NODE GROUP ########################
module "eks-addons-post-nodegroup" {
  source = "../modules/eks/add-ons"
  depends_on = [
    module.eks-nodegroup
  ]
  cluster_name = var.cluster_name
  addons       = var.addons_post_nodegroup
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
  eks_tags = {
    "Name" = var.cluster_name
  }
}

######################## BASTION SECURITY GROUP ########################
module "eks_bastion_securitygroup" {
  source      = "../modules/securitygroup/sg-main"
  name        = "${var.prefix}-bastion-sg"
  description = "Security group for bastion server"
  vpc_id      = var.vpc_id
  common_tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
  }
  sg_tags = {
    "Name" = "${var.prefix}-bastion-sg"
  }
}
module "eks_bastion_securitygroup_rules" {
  depends_on = [
    module.eks_bastion_securitygroup
  ]
  source            = "../modules/securitygroup/sg-rules"
  security_group_id = module.eks_bastion_securitygroup.securitygroup_id
  ingress_with_cidr_blocks = [
    ({
      "description" = "Allow SSH to bastion communication"
      "from_port"   = 22
      "protocol"    = "tcp"
      "to_port"     = 22
      "cidr_blocks" = ["0.0.0.0/0"]
    })
  ]
  egress_with_cidr_blocks = [
    ({
      "description" = "Allow all outbound communication"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
      "cidr_blocks" = ["0.0.0.0/0"]
    })
  ]
}

######################## EKS CONFIG MAPS ########################
module "eks_auth" {
  depends_on = [
    module.eks-nodegroup
  ]
  source = "../modules/eks/eks-auth-config-map"
  eks = {
    eks_managed_node_groups            = module.eks-nodegroup
    fargate_profiles                   = []
    cluster_endpoint                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_certificate_authority_data = data.aws_eks_cluster.cluster.certificate_authority.0.data
  }

  map_roles = [
    {
      rolearn  = module.eks_nodegroup_role.eks_nodegroup_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = module.bastion_role.arn
      username = "bastion-role"
      groups   = ["system:masters"]
    }
  ]

  map_users = var.configmap_users

  map_accounts = []
}

######################## BASTION SERVER ########################
module "bastion_role" {
  source                        = "../modules/IAM/EC2"
  name                          = "${var.cluster_name}-bastion-role"
  bastion_policy_arns           = var.bastion_policy_arns
  bastion_custom_policies       = var.bastion_custom_policies
  bastion_instance_profile_name = var.bastion_instance_profile_name
}

module "bastion_server" {
  depends_on = [
    module.eks,
    module.bastion_role,
    module.eks_bastion_securitygroup,
    module.eks_auth,
    module.eks-nodegroup
  ]
  source                      = "../modules/EC2/EC2"
  name                        = "${var.cluster_name}-bastion"
  ami                         = var.bastion_ami
  ec2_subnet_ids              = var.ec2_subnet
  key_name                    = var.bastion_key_pair
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.eks_bastion_securitygroup.securitygroup_id]
  iam_instance_profile        = module.bastion_role.profile_name
  instance_type               = "t2.micro"
  tags = {
    "environment" = var.environment
    "region"      = var.region
    "account"     = var.AccountId
    "Created-By"  = var.created_by
    "Name"        = "${var.cluster_name}-bastion"
  }
  #Script to be run for installation of kubectl and helm and updating kubeconfig
  inline-remote-exec = [
    "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.9/2023-01-11/bin/linux/amd64/kubectl",
    "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.9/2023-01-11/bin/linux/amd64/kubectl.sha256",
    "openssl sha1 -sha256 kubectl",
    "chmod +x ./kubectl",
    "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin",
    "echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc",
    "curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash",
    "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  ]
}

######################## CLUSTER AUTOSCALER ########################
module "cluster_autoscaler" {
  source = "../modules/eks/cluster-autoscaler"
  depends_on = [
    module.eks,
    module.eks-nodegroup,
    module.eks-addons-post-nodegroup
  ]
  enabled                          = true
  cluster_name                     = module.eks.cluster_id
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  aws_region                       = var.region
}

######################## EXTERNAL DNS ########################
module "external_dns" {
  depends_on = [
    module.eks,
    module.eks-nodegroup,
    module.eks-addons-post-nodegroup
  ]
  source                           = "../modules/eks/eks-external-dns"
  cluster_name                     = var.cluster_name
  region                           = var.region
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  create_namespace                 = false
  namespace                        = "kube-system"
  enabled                          = true
  policy_allowed_zone_ids          = [data.aws_route53_zone.cloud_hosted_zone.zone_id]
  service_account_name             = "external-dns"
  settings = {
    "policy"        = "sync" # Modify how DNS records are sychronized between sources and providers.
    "zoneIdFilters" = [data.aws_route53_zone.cloud_hosted_zone.zone_id]
  }
}

# data "aws_route53_zone" "private_hosted_zone" {
#   name         = "sidtalks.online"
#   private_zone = true
# }

data "aws_route53_zone" "cloud_hosted_zone" {
  name = "sidview.online"
}

######################## ALB INGRESS CONTROLLER ROLE ########################
locals {
  oidc_for_alb-ingress = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")
  ingress-controller_trust_policy = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_for_alb-ingress}:aud" : "sts.amazonaws.com",
            "${local.oidc_for_alb-ingress}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  }
}

module "alb-controller_role" {
  source                         = "../modules/IAM/alb-ingress-controller"
  name                           = var.alb_ingress_role_name
  alb_controller_policy_arns     = var.alb_ingress_controller_policy_arns
  alb_controller_custom_policies = var.alb_ingress_controller_custom_policies
  alb_controller-trust-policy    = local.ingress-controller_trust_policy
}