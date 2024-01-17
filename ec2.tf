# get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
}

# create key pair
resource "aws_key_pair" "key_pair" {
    key_name   = "id_rsa"
    public_key = file(var.public_key_path)
}

# create production ec2 instance
resource "aws_instance" "dev_instance" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    user_data = <<-EOF
        #!/bin/bash
        set -ex
        sudo yum update -y
        sudo amazon-linux-extras install docker -y
        sudo service docker start
        export DOCKER_USERNAME="${var.docker_username}"
        export DOCKER_PASSWORD="${var.docker_password}"
        export GITHUB_USERNAME="${var.github_username}"
        export GITHUB_TOKEN="${var.github_pat}"
        sudo docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD
        sudo usermod -a -G docker ec2-user
        sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        git config --global user.name $GIT_USERNAME
        git config --global user.email "bmitchum.dev@gmail.com"
        git remote set-url origin "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/b-mitch/woutfh_prod.git"
        git clone "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/b-mitch/woutfh_prod.git"
    EOF

    vpc_security_group_ids      = [aws_security_group.dev_webserver_security_group.id]
    # iam_instance_profile      = aws_iam_instance_profile.ec2_profile.name
    subnet_id                   = aws_subnet.private_app_subnet.id
    # associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name

    tags = {
        Name = "dev-instance"
    }
}
