####EC@ INSTANCES FOR BASTION#################

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id] # this is secruity group for bastion
  subnet_id = local.public_subnet_id #subnet id
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  user_data = file("${path.module}/userdata.sh")
   
  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true

    tags = merge(
    {
        Name = "${local.common_name}-bastion"
    },
    local.common_tags
  )
  }
  tags = merge(
    {
        Name = "${local.common_name}-bastion"
    },
    local.common_tags
  )
}

# FOR EXTENDING THE PARTISION
# lsblk
# growpart /dev/nvme0n1 4
# lvextend -r -L +30G /dev/mapper/RootVG-rootVol
# xfs_growfs /
# df -hT
#DELETE COMMAND FOR ALL AT A ONCE
# for i in 40-databases/ 30-bastion/ 20-sg-rules/ 10-sg/ 00-vpc/; do cd $i; terraform destroy -auto-approve; cd ..;done