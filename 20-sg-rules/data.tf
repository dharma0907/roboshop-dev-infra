#mongodb
data "aws_ssm_parameter" "mongodb_sg_id" {
    name = "/${var.project}/${var.environment}/mongodb_sg_id"
}

#redis
data "aws_ssm_parameter" "redis_sg_id" {
    name = "/${var.project}/${var.environment}/redis_sg_id"
}

#mysql
data "aws_ssm_parameter" "mysql_sg_id" {
    name = "/${var.project}/${var.environment}/mysql_sg_id"
}

#rabbitmq
data "aws_ssm_parameter" "rabbitmq_sg_id" {
    name = "/${var.project}/${var.environment}/rabbitmq_sg_id"
}

#catalogue secruity group id
data "aws_ssm_parameter" "catalogue_sg_id" {
    name = "/${var.project}/${var.environment}/catalogue_sg_id"
}
#user
data "aws_ssm_parameter" "user_sg_id" {
    name = "/${var.project}/${var.environment}/user_sg_id"
}

#cart
data "aws_ssm_parameter" "cart_sg_id" {
    name = "/${var.project}/${var.environment}/cart_sg_id"
}

#shipping
data "aws_ssm_parameter" "shipping_sg_id" {
    name = "/${var.project}/${var.environment}/shipping_sg_id"
}

#payment
data "aws_ssm_parameter" "payment_sg_id" {
    name = "/${var.project}/${var.environment}/payment_sg_id"
}

#backend
data "aws_ssm_parameter" "backend_alb_sg_id" {
    name = "/${var.project}/${var.environment}/backend_alb_sg_id"
}

#frontend
data "aws_ssm_parameter" "frontend_sg_id" {
    name = "/${var.project}/${var.environment}/frontend_sg_id"
}

#frontend LB
data "aws_ssm_parameter" "frontend_alb_sg_id" {
    name = "/${var.project}/${var.environment}/frontend_alb_sg_id"
}

#bastion
data "aws_ssm_parameter" "bastion_sg_id" {
    name = "/${var.project}/${var.environment}/bastion_sg_id"
}

#this is for my ip
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}