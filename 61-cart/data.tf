data "aws_ssm_parameter" "cart_sg_id" {
    name = "/${var.project}/${var.environment}/cart_sg_id"
}
# we are creating cart instance in private subnet
data "aws_ssm_parameter" "private_subnet_ids" {

  name = "/${var.project}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {

  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "backend_alb_listener_arn" {

  name = "/${var.project}/${var.environment}/backend_alb_listener_arn"
}

## ami id we are taking form aws account which is already exists
data "aws_ami" "joindevops" {
  most_recent      = true
  owners           = ["973714476881"]

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# output  "ami_id" {
#   value       = data.aws_ami.joindevops.id
# }
