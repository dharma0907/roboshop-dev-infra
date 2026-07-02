resource "aws_acm_certificate" "roboshop" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-certificate"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}
# AFTER CREATING CERTIFICATE WE CAN COPY THE ARN INTO SSM PARAMATERS


# need to validate
#Referencing domain_validation_options With for_each Based Resources
resource "aws_route53_record" "roboshop" {
  for_each = {
    for dvo in aws_acm_certificate.roboshop.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zoneid
}
# certificate validation block
resource "aws_acm_certificate_validation" "roboshop" {
  certificate_arn         = aws_acm_certificate.roboshop.arn
  validation_record_fqdns = [for record in aws_route53_record.roboshop : record.fqdn]
}