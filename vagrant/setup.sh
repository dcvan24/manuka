#!/bin/bash 

# Install Docker CE
sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common jq gcc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
cat | sudo tee /etc/docker/daemon.json <<EOF
{
    "experimental": true
}
EOF
sudo service docker restart
sudo usermod -aG docker vagrant


# Install Go 1.12
sudo snap install go --classic

cat | tee -a ${HOME}/.bashrc <<EOF
export GOPATH=${HOME}/go
EOF
source ${HOME}/.bashrc
