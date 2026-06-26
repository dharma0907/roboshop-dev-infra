resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id #taking vpc id value form outputs
  overwrite = true
}

# now we will store public subent ids oinssm parameter store
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"
  type  = "String"
  value = join(",",module.vpc.public_subnet_ids)
  overwrite = true
}



# now we will store private subent ids oinssm parameter store
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"
  type  = "String"
  value = join(",",module.vpc.private_subnet_ids)
  #value = join(", ", ["foo", "bar", "baz"]) this join is used to convert list to string using comma separator
  overwrite = true
}

# now we will store database subent ids in ssm parameter store
resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_subnet_ids"
  type  = "String"
  value = join(",",module.vpc.database_subnet_ids)
  overwrite = true
}