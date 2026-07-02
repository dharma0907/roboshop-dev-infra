

#this is security group id  for frontend alb security group id, stored in SSM
data "aws_ssm_parameter" "frontend_alb_sg_id" {
  name = "/${var.project}/${var.environment}/frontend_alb_sg_id"
}

# FRONTEND ALB WILL BE IN PUBLIC SUBNET
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project}/${var.environment}/public_subnet_ids"
}


data "aws_ssm_parameter" "certificate_arn" {
  name = "/${var.project}/${var.environment}/certificate_arn"
}

# output  "ami_id" {
#   value       = data.aws_ami.joindevops.id
# }
