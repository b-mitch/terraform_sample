# create security group for the production web server
# terraform aws create security group
resource "aws_security_group" "prod_webserver_security_group" {
    name        = "prod-webserver-security-group"
    description = "enable http/http access on port 80 and access on port 22 via ssh sg"
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
        Name = "prod-webserver-security-group"
    }
}

# create security group for the development web server
# terraform aws create security group
resource "aws_security_group" "dev_webserver_security_group" {
    name        = "dev-webserver-security-group"
    description = "enable access on port 22 via ssh sg"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_location]
    }

    ingress {
        description = "postgres access"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.prod_database_security_group.id]
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
        security_groups = [aws_security_group.prod_webserver_security_group.id]
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
