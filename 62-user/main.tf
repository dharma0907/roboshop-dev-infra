resource "aws_instance" "user" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.user_sg_id]
  subnet_id = local.private_subnet_id
  
  tags = merge(
    {
        Name = "${local.common_name}-user-${var.app_version}-${var.environment}"
    },
    local.common_tags
  )
}

#calling terraform data resource
resource "terraform_data" "user" {
  triggers_replace = [
    aws_instance.user.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.user.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh user ${var.environment} ${var.app_version}"
    ]
  }
}

# 3. now we need to stop instance, Control the state of the instance
resource "aws_ec2_instance_state" "user" {
  instance_id = aws_instance.user.id
  state       = "stopped" # Change to "running" to start it back up
  depends_on = [ terraform_data.user ] # we are saying stop only after creating and configuring instance, so 1 and 2 should manadetory to run 3
}

# 4. Take or create ami template, this ami temolate we are taking form existing instance
resource "aws_ami_from_instance" "user" {
  name               = "${local.common_name}-user-${var.app_version}-${aws_instance.user.id}"
  source_instance_id = aws_instance.user.id
  depends_on = [ aws_ec2_instance_state.user ] # this depends upon 3
  tags = merge(
    {
        Name = "${local.common_name}-user-${var.app_version}-${aws_instance.user.id}"
    },
    local.common_tags
  )

}


# 5 launch template for user
resource "aws_launch_template" "user" {
  name = "${local.common_name}-user-launch-template"
  image_id = aws_ami_from_instance.user.id # we are taking from current instance
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.user_sg_id]

  tag_specifications {
    resource_type = "instance"

     tags = merge(
         {
           Name = "${local.common_name}-user-${var.app_version}-${aws_instance.user.id}"
       },
    local.common_tags
   )

  }

  # with onstance it will create a EBS volume, we can add tags for volume as well
   tag_specifications {
    resource_type = "volume"

     tags = merge(
         {
           Name = "${local.common_name}-user-${var.app_version}-${aws_instance.user.id}"
       },
    local.common_tags
   )
  }
#launch template tags
     tags = merge(
         {
           Name = "${local.common_name}-user-${var.app_version}-${aws_instance.user.id}"
       },
    local.common_tags
   )
 
}

# 6. after creating launch template, need to create target group
resource "aws_lb_target_group" "user" {
  name     = "${local.common_name}-user-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30
  
  # if we are creating target group, we need to create health checks
  health_check {
    healthy_threshold = 2
    interval = 30
    path = "/health"
    port = "8080"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

# 7. AUTO SCALING GROUP
resource "aws_autoscaling_group" "user" {
  name                      = "${local.common_name}-user-asg"
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  launch_template {
    id      = aws_launch_template.user.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]
  #we need target group id here, to target particulat instance
  target_group_arns          = [aws_lb_target_group.user.arn]

   instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

    dynamic "tag" {
    for_each = merge(
      {
        Name = "${local.common_name}-user"
      },
      local.common_tags
    )
    content{
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }


  timeouts {
    delete = "15m"
  }
 
}

# 8. Auto scale policy creation
resource "aws_autoscaling_policy" "user"{
  name                   = "${local.common_name}-user-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.user.name
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0 # Target 75% CPU utilization
  }
}

# 9. alb rule
# Forward action, means it will forward the traffic to particular serivce
resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = local.backend_alb_listener_arn  # we need to get backend ALB listener arn here

  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn
  }

  condition {
    host_header {
      values = ["user.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
}

# 10. we need to delete the stopped instance, because we have created ami from ec2 only, stop instance and taken ami and then created new ec2 instances
resource "terraform_data" "user_delete" {
  triggers_replace = [
    aws_instance.user.id
  ]
  depends_on = [aws_autoscaling_policy.user]

  # executes where terraform is running
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.user.id}"
  }
}