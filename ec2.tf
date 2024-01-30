# create key pair
resource "aws_key_pair" "key_pair" {
    key_name   = "id_rsa"
    public_key = file(var.public_key_path)
}

# create production ec2 instance in public subnet az1
resource "aws_instance" "prod_instance_az1" {
    ami           = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    vpc_security_group_ids      = [aws_security_group.prod_webserver_security_group_az1.id]
    subnet_id                   = aws_subnet.public_prod_subnet_az1.id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name
    user_data                  = file("docker-setup.sh")
    
    tags = {
        Name        = "prod-instance-az1"
        Environment = "blue production"
        Project     = "woutfh"
    }
}

# create production ec2 instance in public subnet az2
resource "aws_instance" "prod_instance_az2" {
    ami           = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    vpc_security_group_ids      = [aws_security_group.prod_webserver_security_group_az2.id]
    subnet_id                   = aws_subnet.public_prod_subnet_az2.id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name
    user_data                  = file("docker-setup.sh")

    tags = {
        Name        = "prod-instance-az2"
        Environment = "green production"
        Project     = "woutfh"
    }
}

# create dev ec2 instance
resource "aws_instance" "dev_instance" {
    ami           = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    vpc_security_group_ids      = [aws_security_group.dev_webserver_security_group.id]
    subnet_id                   = aws_subnet.public_dev_subnet.id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name
    user_data                  = file("docker-setup.sh")

    tags = {
        Name        = "dev-instance"
        Environment = "development"
        Project     = "woutfh"
    }
}
