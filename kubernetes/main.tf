terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.23.1"
    }
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  cluster_name = var.cluster_name
}

locals {
  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = var.owner
    Reason = var.reason
    Description = var.description
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.4"

  cluster_name = local.cluster_name
  cluster_version = "1.28"
  cluster_endpoint_public_access = true
  subnet_ids = concat(var.public_subnets, var.private_subnets)

  vpc_id = var.vpc_id

  tags = local.tags

  # EKS configuration
  manage_aws_auth_configmap = true

  # Node group configuration
  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    collector = {
      name                     = "collector_nodes"
      instance_type            = "t2.small"
      platform                 = "linux"
      key_name                 = "kmullaney"
      min_size                 = 0
      max_size                 = 3
      desired_size             = 1
      create_iam_role          = true
      iam_role_name            = "otel-collector-role"
      iam_role_use_name_prefix = false
      iam_role_description     = "self-managed node group for otel-collector"
      iam_role_tags            = local.tags
      tags                     = local.tags
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
}

output "container_registry" {
  value = var.container_registry
}

output "container_repository" {
  value = var.container_repository
}

# run with:
# terraform apply -auto-approve
# terraform output -json > terraform_output.json
# ./build_and_push.sh \
#   $(jq -r '.container_registry.value' terraform_output.json) \
#   $(jq -r '.container_repository.value' terraform_output.json)
