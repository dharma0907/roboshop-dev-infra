resource "aws_instance" "shipping" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.shipping_sg_id]
  subnet_id = local.private_subnet_id
  
  tags = merge(
    {
        Name = "${local.common_name}-shipping-${var.app_version}-${var.environment}"
    },
    local.common_tags
  )
}

#calling terraform data resource
resource "terraform_data" "shipping" {
  triggers_replace = [
    aws_instance.shipping.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.shipping.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh shipping ${var.environment} ${var.app_version}"
    ]
  }
}

# 3. now we need to stop instance, Control the state of the instance
resource "aws_ec2_instance_state" "shipping" {
  instance_id = aws_instance.shipping.id
  state       = "stopped" # Change to "running" to start it back up
  depends_on = [ terraform_data.shipping ] # we are saying stop only after creating and configuring instance, so 1 and 2 should manadetory to run 3
}

# 4. Take or create ami template, this ami temolate we are taking form existing instance
resource "aws_ami_from_instance" "shipping" {
  name               = "${local.common_name}-shipping-${var.app_version}-${aws_instance.shipping.id}"
  source_instance_id = aws_instance.shipping.id
  depends_on = [ aws_ec2_instance_state.shipping ] # this depends upon 3
  tags = merge(
    {
        Name = "${local.common_name}-shipping-${var.app_version}-${aws_instance.shipping.id}"
    },
    local.common_tags
  )

}


# 5 launch template for shipping
resource "aws_launch_template" "shipping" {
  name = "${local.common_name}-shipping-launch-template"
  image_id = aws_ami_from_instance.shipping.id # we are taking from current instance
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.shipping_sg_id]

  tag_specifications {
    resource_type = "instance"

     tags = merge(
         {
           Name = "${local.common_name}-shipping-${var.app_version}-${aws_instance.shipping.id}"
       },
    local.common_tags
   )

  }

  # with onstance it will create a EBS volume, we can add tags for volume as well
   tag_specifications {
    resource_type = "volume"

     tags = merge(
         {
           Name = "${local.common_name}-shipping-${var.app_version}-${aws_instance.shipping.id}"
       },
    local.common_tags
   )
  }
#launch template tags
     tags = merge(
         {
           Name = "${local.common_name}-shipping-${var.app_version}-${aws_instance.shipping.id}"
       },
    local.common_tags
   )
 
}

# 6. after creating launch template, need to create target group
resource "aws_lb_target_group" "shipping" {
  name     = "${local.common_name}-shipping-tg"
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
resource "aws_autoscaling_group" "shipping" {
  name                      = "${local.common_name}-shipping-asg"
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  launch_template {
    id      = aws_launch_template.shipping.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]
  #we need target group id here, to target particulat instance
  target_group_arns          = [aws_lb_target_group.shipping.arn]

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
        Name = "${local.common_name}-shipping"
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
resource "aws_autoscaling_policy" "shipping"{
  name                   = "${local.common_name}-shipping-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.shipping.name
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

  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shipping.arn
  }

  condition {
    host_header {
      values = ["shipping.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
}

# 10. we need to delete the stopped instance, because we have created ami from ec2 only, stop instance and taken ami and then created new ec2 instances
resource "terraform_data" "shipping_delete" {
  triggers_replace = [
    aws_instance.shipping.id
  ]
  depends_on = [aws_autoscaling_policy.shipping]

  # executes where terraform is running
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.shipping.id}"
  }
}