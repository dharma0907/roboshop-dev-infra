####EC@ INSTANCES FOR BASTION#################

resource "aws_instance" "mongodb" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id] # this is secruity group for mongodb
  subnet_id = local.database_subnet_ids #databse subnet id
     

  tags = merge(
    {
        Name = "${local.common_name}-mongodb"
    },
    local.common_tags
  )
}


#DELETE COMMAND FOR ALL AT A ONCE
# for i in 40-databases/ 30-bastion/ 20-sg-rules/ 10-sg/ 00-vpc/; do cd $i; terraform destroy -auto-approve; cd ..;done

#create
# for i in 00-vpc/ 10-sg/  20-sg-rules/ 40-database/ 30-bastion/ ; do cd $i; terraform apply --auto-approve; cd ..;done

# WE ARE USING TERRAFORM INSTANCE BLOCK OUTSIDE THE INSTANCE.
resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.mongodb.private_ip #this is mongodb private ip
  }
  
   provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
   provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh mongodb ${var.environment}" #it will run .sh with arguments $1=mongodb and $2=dev
    ]
  }
}