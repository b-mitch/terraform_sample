# create production database subnet group
# terraform aws create database subnet group
resource "aws_db_subnet_group" "prod_data_subnet_group" {
    name       = "prod-data-subnet-group"
    subnet_ids = [aws_subnet.private_prod_data_subnet_az1.id, aws_subnet.private_prod_data_subnet_az2.id]
    tags = {
        Name = "prod-data-subnet-group"
    }
}

# create development database subnet group
# terraform aws create database subnet group
resource "aws_db_subnet_group" "dev_data_subnet_group" {
    name       = "dev-data-subnet-group"
    subnet_ids = [aws_subnet.private_dev_data_subnet_az1.id, aws_subnet.private_dev_data_subnet_az2.id]
    tags = {
        Name = "dev-data-subnet-group"
    }
}

# create RDS instance for production
# terraform aws create rds instance
resource "aws_db_instance" "prod_db" {
    engine            = "postgres"
    instance_class    = "db.t3.micro"
    identifier        = "prod-db-instance"
    allocated_storage = 20
    username          = var.prod_db_username
    password          = var.prod_db_password
    engine_version    = "15.4"
    db_subnet_group_name = aws_db_subnet_group.prod_data_subnet_group.name
    vpc_security_group_ids = [aws_security_group.prod_database_security_group.id]

    tags = {
        Name = "prod-db-instance"
    }
}

# create RDS instance for development
# terraform aws create rds instance
resource "aws_db_instance" "dev_db" {
    engine            = "postgres"
    instance_class    = "db.t3.micro"
    identifier        = "dev-db-instance"
    allocated_storage = 20
    username          = var.dev_db_username
    password          = var.dev_db_password
    engine_version    = "15.4"
    db_subnet_group_name = aws_db_subnet_group.dev_data_subnet_group.name
    vpc_security_group_ids = [aws_security_group.dev_database_security_group.id]
    publicly_accessible = true

    tags = {
        Name = "dev-db-instance"
    }
}
