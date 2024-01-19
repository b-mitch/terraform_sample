#!/bin/bash

# Use this Shell Script to Install Ansible on the EC2 Instance

sudo yum install -y python3-pip
sudo python3 -m pip install ansible-core
sudo yum -y install git

