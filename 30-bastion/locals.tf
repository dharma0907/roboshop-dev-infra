locals {
  ami_id = data.aws_ami.joindevops.id
  bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0] #public-subnet-1a 
  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Project = "${var.project}"
    Environment = "${var.environment}"
    Terrafrom = true
  }

}