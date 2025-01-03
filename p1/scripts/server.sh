#!/bin/bash

# Download k3s and install it
# Enable flannel on eth1 (private network)
# Set the kubeconfig file rights to 644 (controller mode)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_KUBECONFIG_MODE="644" sh -
