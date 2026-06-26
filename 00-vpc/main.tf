module "vpc" {
  # normally we take modules form git ot any other regostry, so we need to give path pof that instead folder path of local
  #source = "../terraform-aws-vpc" # this is local path
  source = "git::https://github.com/dharma0907/terraform-aws-vpc.git?ref=main" # this is remote path
  project = var.project
  environment = var.environment
  is_peering_required = false
  
}