#!/bin/bash
component=$1 #catalogue
environment=$2
app_version=$3
sudo dnf install ansible -y
# after installing ansible we need to write log file for ansible
mkdir -p /var/log/roboshop
chown -R ec2-user:ec2-user /var/log/roboshop
chmod -R 755 /var/log/roboshop
touch /var/log/roboshop/ansible.log 

cd /home/ec2-user
git clone https://github.com/dharma0907/roboshop-ansible-v3.git
cd roboshop-ansible-v3
git pull
ansible-playbook roboshop.yaml -e "component=$component" -e "environment=$environment" -e "app_version=$app_version"