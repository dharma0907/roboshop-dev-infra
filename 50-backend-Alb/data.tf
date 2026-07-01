

#this is security group id  for backend alb security group id, stored in SSM
data "aws_ssm_parameter" "backend_alb_sg_id" {
  name = "/${var.project}/${var.environment}/backend_alb_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project}/${var.environment}/private_subnet_ids"
}
# output  "ami_id" {
#   value       = data.aws_ami.joindevops.id
# }
