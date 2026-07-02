# storing backend alb arn in parameter store
resource "aws_ssm_parameter" "backend_alb_listener" {
  name = "/${var.project}/${var.environment}/backend_alb_listener"
  type = "String"
  value = aws_lb_listener.http.arn
  overwrite = true
}
