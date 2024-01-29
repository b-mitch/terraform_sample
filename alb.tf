# create application load balancer
# terraform aws create application load balancer
resource "aws_lb" "alb" {
    name               = "alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_security_group.id]
    subnets            = [aws_subnet.public_prod_subnet_az1.id, aws_subnet.public_prod_subnet_az2.id]
    enable_deletion_protection = false

    tags = {
        Name = "alb"
    }
}

# create target group for the application load balancer
# terraform aws create target group
resource "aws_lb_target_group" "target_group" {
    name        = "target-group"
    target_type = "instance"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id

    health_check {
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200, 301, 302"
        path = "/"
        port = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    tags = {
        Name = "target-group"
    }
}

# create listener for the application load balancer
# terraform aws create listener
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.target_group.arn
        type             = "forward"
    }
}
