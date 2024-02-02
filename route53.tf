# Get ALB DNS name
data "aws_lb" "alb" {
  name = "alb"
}

# Create an A record for the root domain
resource "aws_route53_record" "woutfh_domain" {
  zone_id = "Z07136312IOFHVADAEBK6"  # Created through the console before purchasing the domain
  name    = "woutfh.com"
  type    = "A"
  # ttl    = "300"
  # records = [aws_instance.dev_instance.public_ip] # Specify your EC2 instance's public IP address
  
  alias {
    name                   = data.aws_lb.alb.dns_name # Specify your ALB's DNS name
    zone_id                = "Z35SXDOTRQ7X7K"  # Specify your ALB's hosted zone ID
    evaluate_target_health = true
  }
}

# Create an A record for the www subdomain
resource "aws_route53_record" "www_subdomain" {
  zone_id = "Z07136312IOFHVADAEBK6"  # Created through the console before purchasing the domain
  name    = "www.woutfh.com"
  type    = "A"
  # ttl    = "300"
  # records = [aws_instance.dev_instance.public_ip] # Specify your EC2 instance's public IP address

  alias {
    name                   = data.aws_lb.alb.dns_name # Specify your ALB's DNS name
    zone_id                = "Z35SXDOTRQ7X7K"  # Specify your ALB's hosted zone ID
    evaluate_target_health = true
  }
}