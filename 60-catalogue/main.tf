resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id = local.private_subnet_id
  
  tags = merge(
    {
        Name = "${local.common_name}-catalogue-${var.app_version}-${var.environment}"
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
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
    ]
  }
}

# 3. now we need to stop instance, Control the state of the instance
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped" # Change to "running" to start it back up
  depends_on = [ terraform_data.catalogue ] # we are saying stop only after creating and configuring instance, so 1 and 2 should manadetory to run 3
}

# # 4. Take or create ami template, this ami temolate we are taking form existing instance
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ] # this depends upon 3
  tags = merge(
    {
        Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
    },
    local.common_tags
  )

}


#launch template
resource "aws_launch_template" "catalogue" {
  name = "${local.common_name}-catalogue-launch-template"
  image_id = aws_ami_from_instance.catalogue.id # we are taking from current instance
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]

  tag_specifications {
    resource_type = "instance"

     tags = merge(
         {
           Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
       },
    local.common_tags
   )

  }

  # with onstance it will create a EBS volume, we can add tags for volume as well
   tag_specifications {
    resource_type = "volume"

     tags = merge(
         {
           Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
       },
    local.common_tags
   )
  }
#launch template tags
     tags = merge(
         {
           Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
       },
    local.common_tags
   )
 
}

# after creating launch template, need to create target group
resource "aws_lb_target_group" "catalogue" {
  name     = "${local.common_name}-catalogue-tg"
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

# AUTO SCALING GROUP
resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.common_name}-catalogue-asg"
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]
  #we need target group id here, to target particulat instance
  target_group_arns          = [aws_lb_target_group.catalogue.arn]

    dynamic "tag" {
    for_each = merge(
      {
        Name = "${local.common_name}-catalogue"
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

resource "aws_autoscaling_policy" "catalogue"{
  name                   = "${local.common_name}-catalogue-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0 # Target 75% CPU utilization
  }
}

# alb rule
# Forward action, means i t will forward the traffic to particular serivce

resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = local.backend_alb_listener_arn  # we need to get backend ALB listener arn here

  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
}