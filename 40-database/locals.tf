locals {
  ami_id = data.aws_ami.joindevops.id
  mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id.value
  database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0] #public-subnet-1a 
  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Project = "${var.project}"
    Environment = "${var.environment}"
    Terrafrom = true
  }

}