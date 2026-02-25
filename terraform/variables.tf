# ───────────────────────────────────────────
# General
# ───────────────────────────────────────────

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used as prefix for resource names"
  type        = string
  default     = "online-boutique"
}

variable "environment" {
  description = "Environment name (e.g. test, staging, production)"
  type        = string
  default     = "test"
}

# ───────────────────────────────────────────
# VPC
# ───────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cost saving for non-production)"
  type        = bool
  default     = true
}

# ───────────────────────────────────────────
# EKS
# ───────────────────────────────────────────

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API endpoint"
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 5
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 4
}

# ───────────────────────────────────────────
# Kubernetes
# ───────────────────────────────────────────

variable "namespaces" {
  description = "List of Kubernetes namespaces to create"
  type        = list(string)
  default     = ["staging", "production"]
}

# ───────────────────────────────────────────
# Monitoring (Prometheus + Grafana)
# ───────────────────────────────────────────

variable "kube_prometheus_stack_version" {
  description = "Helm chart version for kube-prometheus-stack"
  type        = string
  default     = "72.6.2"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "grafana_service_type" {
  description = "Kubernetes Service type for Grafana (LoadBalancer for external access, ClusterIP for port-forward)"
  type        = string
  default     = "LoadBalancer"
}

variable "prometheus_retention" {
  description = "How long Prometheus keeps metrics data"
  type        = string
  default     = "7d"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size for Prometheus data"
  type        = string
  default     = "10Gi"
}
