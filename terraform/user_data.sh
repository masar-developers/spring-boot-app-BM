#!/bin/bash
# Update the package repository
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo service docker start
# make docker  autostart
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user

# docker-compose (latest version)
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
# Fix permissions after download
sudo chmod +x /usr/local/bin/docker-compose
# Verify success
docker-compose version

