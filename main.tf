locals {
  cluster_name = "hcp-terraform-001"
  account_role_prefix = local.cluster_name
  operator_role_prefix = local.cluster_name
  vpc_name_prefix = local.cluster_name
}

############################
# Cluster
############################
module "hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.6.6-prerelease.1"

  cluster_name           = local.cluster_name
  openshift_version      = "4.16.5"
  machine_cidr           = module.vpc.cidr_block
  aws_subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  aws_availability_zones = module.vpc.availability_zones
  replicas               = length(module.vpc.availability_zones)

  // STS configuration
  create_account_roles  = true
  account_role_prefix   = local.account_role_prefix
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = local.operator_role_prefix

  depends_on = [module.vpc]
}

############################
# HTPASSWD IDP
############################
module "htpasswd_idp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/idp"

  cluster_id         = module.hcp.cluster_id
  name               = "htpasswd-idp"
  idp_type           = "htpasswd"
  htpasswd_idp_users = [{ username = "test-user", password = random_password.password.result }]
}

resource "random_password" "password" {
  length  = 14
  special = true
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 1
}

############################
# VPC
############################
module "vpc" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/vpc"

  name_prefix              = local.vpc_name_prefix
  availability_zones_count = 3
}
