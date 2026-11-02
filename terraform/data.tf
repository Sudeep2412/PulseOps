data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_az1c" {
  id = var.subnet_id
}

data "aws_iam_instance_profile" "existing_ec2_profile" {
  name = var.iam_instance_profile_name
}
