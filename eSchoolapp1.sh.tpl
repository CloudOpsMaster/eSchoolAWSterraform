#!/bin/bash

#Updating OS
sudo apt update && sudo apt upgrade -y

# #Installing Java
sudo apt install openjdk-8-jdk-headless maven -y
sudo update-java-alternatives -s java-1.8.0-openjdk-amd64

sudo apt install git -y

# Install curl
sudo apt install curl

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

# Install gitlab-runner
sudo apt-get install gitlab-runner

# for DEB based systems
sudo apt-cache madison gitlab-runner
sudo apt-get install gitlab-runner=10.0.0

# gitlab-runner register
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "${registration_token}" \
  --executor "shell" \
  --description "app1 runner" \
  --tag-list "eSchool" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
sudo usermod -aG sudo gitlab-runner