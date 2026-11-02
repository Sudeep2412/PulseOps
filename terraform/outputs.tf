output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "EC2 instance public IP address"
  value       = module.compute.public_ip
}

output "ec2_private_ip" {
  description = "EC2 instance private IP address"
  value       = module.compute.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.networking.security_group_id
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "Amazon ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "github_oidc_role_arn" {
  description = "GitHub Actions OIDC IAM role ARN"
  value       = module.iam.github_actions_role_arn
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC identity provider ARN"
  value       = module.iam.github_oidc_provider_arn
}
