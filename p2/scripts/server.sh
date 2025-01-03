#!/bin/bash

# I had to change ip from 127.0.0.1 to inet1 ip address.
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_KUBECONFIG_MODE="644" sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface eth1 --bind-address $(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')" K3S_KUBECONFIG_MODE="644" sh -

# in Vagrant VM ,  k3s always starts before "default" namespace created.
# Now system waits until default namespace created.
 
# until kubectl cluster-info &>/dev/null; do sleep 1; done

until kubectl get namespace default &>/dev/null; do 
    echo "Waiting for default namespace..."
    sleep 3
done

cd /vagrant/confs
kubectl apply -f "deployment.yaml"
kubectl apply -f "service.yaml"
kubectl apply -f ingress.yaml