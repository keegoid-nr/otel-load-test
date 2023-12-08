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

variable "container_registry" {
  description = "Container repository for the otel-load-test app"
  type        = string
}

variable "container_repository" {
  description = "Go module for the otel-load-test app"
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

variable "log_exporter_log_verbosity" {
  description = "Verbosity level for the logging exporter"
  type        = string
  default     = "detailed"  # Set a default or remove this line to require an explicit value
}

variable "NEW_RELIC_OTLP_ENDPOINT" {
  description = "The New Relic OTLP endpoint for metrics"
  type        = string
}

variable "NEW_RELIC_API_KEY" {
  description = "The New Relic API key"
  type        = string
}
