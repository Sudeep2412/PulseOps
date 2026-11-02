module "networking" {
  source = "./modules/networking"

  vpc_id               = data.aws_vpc.default.id
  authorized_ssh_cidrs = var.authorized_ssh_cidrs
}

module "compute" {
  source = "./modules/compute"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  availability_zone         = var.availability_zone
  subnet_id                 = var.subnet_id
  security_group_id         = module.networking.security_group_id
  iam_instance_profile_name = data.aws_iam_instance_profile.existing_ec2_profile.name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "iam" {
  source = "./modules/iam"

  ecr_repository_arn = module.ecr.repository_arn
}
