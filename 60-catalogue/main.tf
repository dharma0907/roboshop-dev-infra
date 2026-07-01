resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id = local.private_subnet_id
  
  tags = merge(
    {
        Name = "${local.common_name}-catalogue"
    },
    local.common_tags
  )
}

#calling terraform data resource
resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
    ]
  }
}

# # 3. now we need to stop instance, Control the state of the instance
# resource "aws_ec2_instance_state" "catalogue" {
#   instance_id = aws_instance.catalogue.id
#   state       = "stopped" # Change to "running" to start it back up
#   depends_on = [ terraform_data.catalogue ] # we are saying stop only after creating and configuring instance, so 1 and 2 should manadetory to run 3
# }

# # 4. Take or create ami template
# resource "aws_ami_from_instance" "example" {
#   name               = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
#   source_instance_id = aws_instance.catalogue.id
#   depends_on = [ aws_ec2_instance_state.catalogue ] # this depends upon 3
#   tags = merge(
#     {
#         Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
#     },
#     local.common_tags
#   )

# }