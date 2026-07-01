#aws load balancer creation code
resource "aws_lb" "backend_alb" {
  name               = "${local.common_name}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = true


  tags = merge(
    {
        Name = "${local.common_name}-backend-alb"
    },
    local.common_tags

  ) 
    
  
}

#for load baalancer we need to create listner
resource "aws_lb" "front_end" {
  # ...
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

     fixed_response {
      content_type = "text/plain"
      message_body = "<h1> Hi, i am from backend alb terraform code</h1>"
      status_code  = "200"
    }
  }
}


resource "aws_route53_record" "www" {
  zone_id = var.zoneid
  name    = "*.backend-alb-${var.environment}.dcinema.online" # *.backend-alb-dev.dcinema.com
  type    = "A"
  ttl     = 300
   
    # featching 
   alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}