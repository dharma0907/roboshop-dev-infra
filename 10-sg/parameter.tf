# WE ARE STORING SECRUITY GROUP ID IN SSM PARAMETER, WE HAVE MULTIPLE SG NAMES SO USING COUNT
resource "aws_ssm_parameter" "sg_id" {
  count = length(var.sg_names) # this is mandetory, or else script will fail
  name = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"
  type = "String"
  value = module.sg[count.index].sg_id #we are getting secruity group id's
  overwrite = true
}