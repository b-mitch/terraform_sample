#!/bin/bash

# Install Docker
sudo yum update
sudo yum install -y docker
# Add ec2-user to the docker group so you can execute Docker commands without using sudo.
sudo service docker start
sudo chkconfig docker on
sudo usermod -aG docker ec2-user