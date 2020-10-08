#!/bin/bash
# https://www.exoscale.com/syslog/autoscaling-with-grafana-and-prometheus/

# Exit immediately if a command exits with a non-zero exit status.
set -e

#To make the environment variable persist for your session, run https://linuxhint.com/debian_frontend_noninteractive/
export DEBIAN_FRONTEND=noninteractive

# region Install Docker
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
# endregion

# region Launch containers

# Run the load generator
docker run -d \
  --restart=always \
  -p 80:8080 \
  janoszen/http-load-generator:1.0.1
# -p 8080 :8080 security rule for 8080 (binding outside)