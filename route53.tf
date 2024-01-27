# Create an A record for the root domain
resource "aws_route53_record" "woutfh_domain" {
  zone_id = "Z07136312IOFHVADAEBK6"  # Created through the console before purchasing the domain
  name    = "woutfh.com"
  type    = "A"
  ttl     = "300"
  records = ["44.193.200.207"]  # The public IP of the EC2 instance
}

# Create an A record for the www subdomain
resource "aws_route53_record" "www_subdomain" {
  zone_id = "Z07136312IOFHVADAEBK6"  # Created through the console before purchasing the domain
  name    = "www.woutfh.com"
  type    = "A"
  ttl     = "300"
  records = ["44.193.200.207"] # The public IP of the EC2 instance
}