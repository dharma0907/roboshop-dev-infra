
#mongodb-dcinema.online
resource "aws_route53_record" "mongodb" {
  zone_id = var.zoneid
  name    = "mongodb-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mongodb.private_ip]
}

#redis-dev-dcinema.online
resource "aws_route53_record" "redis" {
  zone_id = var.zoneid
  name    = "redis-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.redis.private_ip]
}

#rabbitmq-dev-dcinema.online
resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zoneid
  name    = "rabbitmq-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.rabbitmq.private_ip]
}