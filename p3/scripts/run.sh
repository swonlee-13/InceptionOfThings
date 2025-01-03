#!/bin/bash

# Create the k3d cluster with one agent node
k3d cluster create cluster -p "8888:30001@agent:0" --agents 1

sudo k3d kubeconfig get cluster > $HOME/.kube/config

k3d kubeconfig merge cluster --kubeconfig-switch-context

# Display cluster information
kubectl cluster-info

# Create necessary namespaces
kubectl apply -f  ../confs/namespace/namespace.yaml

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server to be ready
sleep 10
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

#  apply argoCD project && argoCD application
kubectl apply -f ../confs/argocd/project.yaml
kubectl apply -f ../confs/argocd/application.yaml

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 5000:443 &>/dev/null &

# Retrieve the initial admin password for ArgoCD
PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

# Allow some time for ArgoCD to initialize
sleep 20

# Login to ArgoCD
argocd login localhost:5000 --username admin --password $PASSWORD --insecure

# Provide login details
echo "You can now login to ArgoCD on localhost:5000"
echo "Username: admin"
echo "Password: $PASSWORD, open [pass] file to copy"
echo "Password: $PASSWORD" > pass
