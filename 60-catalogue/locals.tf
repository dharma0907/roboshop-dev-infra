locals {
    catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
    ami_id = data.aws_ami.joindevops.id
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_name = "${var.project}-${var.environment}"
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0] #here 0 index will fetch the data
    common_tags = {
        Project = "${var.project}"
        Environment = "${var.environment}"
        Terraform = "true"
    }
}