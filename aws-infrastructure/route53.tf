resource "aws_route53_zone" "route53-zone" {
  name = var.domain_name
}

# DNS Record
resource "aws_route53_record" "final_project_record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.final_project_alb.dns_name
    zone_id                = aws_lb.final_project_alb.zone_id
    evaluate_target_health = true
  }
}
