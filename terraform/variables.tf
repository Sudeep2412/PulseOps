variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for PulseOps EC2 host (Ubuntu 26.04.1 LTS x86_64)"
  type        = string
  default     = "ami-0d97d7f07b25dd693"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m7i-flex.large"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "project"
}

variable "availability_zone" {
  description = "Target availability zone"
  type        = string
  default     = "us-east-1c"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
  default     = "subnet-0c7dc2e5fa26454f8"
}

variable "iam_instance_profile_name" {
  description = "Pre-existing IAM instance profile name for EC2"
  type        = string
  default     = "instanceRoleproj"
}

variable "authorized_ssh_cidrs" {
  description = "Authorized CIDR blocks for SSH access"
  type        = list(string)
  default = [
    "110.224.84.50/32",
    "171.79.61.8/32"
  ]
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name"
  type        = string
  default     = "pulseops-app"
}

variable "github_repository" {
  description = "GitHub repository path in owner/repo format"
  type        = string
  default     = "Sudeep2412/PulseOps"
}
