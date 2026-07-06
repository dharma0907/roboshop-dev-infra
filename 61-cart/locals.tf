locals {
    cart_sg_id = data.aws_ssm_parameter.cart_sg_id.value
    ami_id = data.aws_ami.joindevops.id
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    backend_alb_listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value
    common_name = "${var.project}-${var.environment}"
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0] #here 0 index will fetch the data from the subent list, maybe us-east-1a
    common_tags = {
        Project = "${var.project}"
        Environment = "${var.environment}"
        Terraform = "true"
    }
}