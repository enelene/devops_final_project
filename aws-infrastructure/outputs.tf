output "alb_dns_name" {
  value = aws_lb.final_project_alb.dns_name
}
output "web_public_ips" {
  value = [for instance in aws_instance.final_web : instance.public_ip]
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# Output the necessary information for GitLab CI/CD
output "bastion_host_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_ssh_key" {
  value     = tls_private_key.final_project_key.private_key_pem
  sensitive = true
}

output "bastion_known_hosts" {
  value = "${aws_instance.bastion.public_ip} ${tls_private_key.final_project_key.public_key_openssh}"
}

output "route53_nameservers" {
  value = aws_route53_zone.route53-zone.name_servers
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_subnet_1.id} ${aws_subnet.private_subnet_2.id}"
}


# output "cloudfront_domain_name" {
#   value = aws_cloudfront_distribution.my_distribution.domain_name
# }


