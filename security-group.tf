# create security group for the application load balancer
# terraform aws create security group
resource "aws_security_group" "alb_security_group" {
    name        = "alb-security-group"
    description = "enable http/https access on port 80 and 443"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "alb-security-group"
    }
}

# create security group for the production web server in az1
# terraform aws create security group
resource "aws_security_group" "prod_webserver_security_group_az1" {
    name        = "prod-webserver-security-group-az1"
    description = "enable http/https access on ports 80/443 and access on port 22 via ssh"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_security_group.id]
    }

    ingress {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_security_group.id]
    }

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_location]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "prod-webserver-security-group-az1"
    }
}

# create security group for the production web server in az2
# terraform aws create security group
resource "aws_security_group" "prod_webserver_security_group_az2" {
    name        = "prod-webserver-security-group-az2"
    description = "enable http/https access on ports 80/443 and access on port 22 via ssh"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_security_group.id]
    }

    ingress {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_security_group.id]
    }

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_location]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "prod-webserver-security-group-az2"
    }
}

# create security group for the development web server
# terraform aws create security group
resource "aws_security_group" "dev_webserver_security_group" {
    name        = "dev-webserver-security-group"
    description = "enable http/https access on ports 80/443 and access on port 22 via ssh"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_location]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-webserver-security-group"
    }
}

# create security group for the production database server
# terraform aws create security group
resource "aws_security_group" "prod_database_security_group" {
    name        = "prod-database-security-group"
    description = "enable access on port 5432 from production webserver sg"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "postgres access"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.prod_webserver_security_group_az1.id, aws_security_group.prod_webserver_security_group_az2]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "prod-database-security-group"
    }
}

# create security group for the development database server
# terraform aws create security group
resource "aws_security_group" "dev_database_security_group" {
    name        = "dev-database-security-group"
    description = "enable access on port 5432 from development webserver sg"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "postgres access"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.dev_webserver_security_group.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-database-security-group"
    }
}

# Add ingress rule to production webserver az1 security group allowing traffic from RDS security group
# Terraform aws create security group rule
resource "aws_security_group_rule" "prod_webserver_az1_ingress_from_db" {
  security_group_id = aws_security_group.prod_webserver_security_group.id

  type        = "ingress"
  description = "allow traffic from production RDS security group"
  from_port   = 5432 
  to_port     = 5432
  protocol    = "tcp"
  source_security_group_id = aws_security_group.prod_database_security_group.id
}

# Add ingress rule to production webserver az2 security group allowing traffic from RDS security group
# Terraform aws create security group rule
resource "aws_security_group_rule" "prod_webserver_az2_ingress_from_db" {
  security_group_id = aws_security_group.prod_webserver_security_group_az2.id

  type        = "ingress"
  description = "allow traffic from production RDS security group"
  from_port   = 5432 
  to_port     = 5432
  protocol    = "tcp"
  source_security_group_id = aws_security_group.prod_database_security_group.id
}

# Add ingress rule to development webserver security group allowing traffic from RDS security group
# Terraform aws create security group rule
resource "aws_security_group_rule" "dev_webserver_ingress_rule" {
  security_group_id = aws_security_group.dev_webserver_security_group.id

  type        = "ingress"
  description = "allow traffic from development RDS security group"
  from_port   = 5432 
  to_port     = 5432
  protocol    = "tcp"
  source_security_group_id = aws_security_group.dev_database_security_group.id
}
