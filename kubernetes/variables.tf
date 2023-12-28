variable "aws_region" {
  description = "AWS region for the EKS cluster"
  default     = "us-west-2"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "my-eks-cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  default     = "1.28"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "registry_name" {
  description = "Registry for the otel-load-test image"
  type        = string
}

variable "repository_name" {
  description = "Repository for the otel-load-test image"
  type        = string
}

variable "runtime" {
  description = "Runtime for the otel-load-test app"
  type        = string
}

variable "owner" {
  description = "New Relic username"
  type        = string
}

variable "reason" {
  description = "case #00123456"
  type        = string
}

variable "description" {
  description = "What is the purpose?"
  type        = string
}

variable "NEW_RELIC_OTLP_ENDPOINT" {
  description = "The New Relic OTLP endpoint for metrics"
  type        = string
}

variable "NEW_RELIC_API_KEY" {
  description = "The New Relic API key"
  type        = string
}

variable "LOG_EXPORTER_VERBOSITY" {
  description = "Verbosity level for the logging exporter"
  type        = string
  default     = "basic"
}

variable "OTEL_CONFIG_COMPLEXITY" {
  description = "Which config yaml to use"
  type        = string
  default     = "simple"
}
