#aws load balancer creation code
resource "aws_lb" "frontend_alb" {
  name               = "${local.common_name}-frontend-alb"
  internal           = false # because this is frontend for public access
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false


  tags = merge(
    {
        Name = "${local.common_name}-frontend-alb"
    },
    local.common_tags

  ) 
    
  
}

#for load baalancer we need to create listner
# resource "aws_lb" "front_end" {
#   # ...
# }

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn


  default_action {
    type = "fixed-response"

     fixed_response {
      content_type = "text/plain"
      message_body = "<h1> Hi, i am from HTTS FRONTEND ALB  terraform code</h1>"
      status_code  = "200"
    }
  }
}


resource "aws_route53_record" "www" {
  zone_id = var.zoneid
  name    = "${var.project}-${var.environment}.dcinema.online" # roboshop-dev.dcinema.online
  type    = "A"
  #ttl     = 300
   
    # featching 
   alias {
    #aws details
    name                   = aws_lb.frontend_alb.dns_name#*.frontend-alb-dev.dcinema.com
    zone_id                = aws_lb.frontend_alb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}