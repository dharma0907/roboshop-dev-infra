####EC@ INSTANCES FOR BASTION#################
#create order
# for i in 00-vpc/ 10-sg/  20-sg-rules/ 40-database/ 30-bastion/ ; do cd $i; terraform apply --auto-approve; cd ..;done

#DELETE COMMAND FOR ALL AT A ONCE, DON"T DELETE VPC FIRST, least first delete
# for i in 40-databases/ 30-bastion/ 20-sg-rules/ 10-sg/ 00-vpc/; do cd $i; terraform destroy -auto-approve; cd ..;done

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
      "sudo /tmp/bootstrap.sh mongo ${var.environment}" #it will run .sh with arguments $1=mongodb and $2=dev
    ]
  }
}


#REDIS INSTANCE CREATION 
resource "aws_instance" "redis" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.redis_sg_id] # this is secruity group for redis
  subnet_id = local.database_subnet_ids #databse subnet id
     

  tags = merge(
    {
        Name = "${local.common_name}-redis"
    },
    local.common_tags
  )
}


# WE ARE USING TERRAFORM INSTANCE BLOCK OUTSIDE THE INSTANCE.
resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.redis.private_ip #this is redis private ip
  }
  
   provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
   provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh redis ${var.environment}" #it will run .sh with arguments $1=redis and $2=dev
    ]
  }
}



#RABBITMQ INSTANCE CREATION 
resource "aws_instance" "rabbitmq" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.rabbitmq_sg_id] # this is secruity group for rabbitmq
  subnet_id = local.database_subnet_ids #databse subnet id
     

  tags = merge(
    {
        Name = "${local.common_name}-rabbitmq"
    },
    local.common_tags
  )
}


# WE ARE USING TERRAFORM INSTANCE BLOCK OUTSIDE THE INSTANCE.
resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.rabbitmq.private_ip #this is rabbitmq private ip
  }
  
   provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
   provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh rabbitmq ${var.environment}" #it will run .sh with arguments $1=rabbitmq and $2=dev
    ]
  }
}


#MYSQL INSTANCE CREATION 
resource "aws_instance" "mysql" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.mysql_sg_id] # this is secruity group for rabbitmq
  subnet_id = local.database_subnet_ids #databse subnet id
  iam_instance_profile = aws_iam_instance_profile.mysql.name # this is iam instance profile for mysql, we are attaching policy to mysql instance
     

  tags = merge(
    {
        Name = "${local.common_name}-mysql"
    },
    local.common_tags
  )
}

resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.mysql.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql ${var.environment}"
    ]
  }
}