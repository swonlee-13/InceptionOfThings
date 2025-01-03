#!/bin/bash

apk add sshpass

SERVER_IP=192.168.56.110
K3S_URL=https://$SERVER_IP:6443

# Wait for the server to be ready
while ! nc -z $SERVER_IP 6443; do
  sleep 1
done

# Retrieve the server node token
TOKEN=$(sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@$SERVER_IP sudo cat /var/lib/rancher/k3s/server/node-token)

# Download k3s and install it
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_URL=$K3S_URL K3S_TOKEN=$TOKEN sh -