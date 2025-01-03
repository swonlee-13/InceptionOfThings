#!/bin/bash

# Delete the ArgoCD application
argocd app delete playground

# Delete the ArgoCD project
argocd proj delete playground

# Terminate the port-forwarding process for ArgoCD UI
pkill -f "kubectl port-forward svc/argocd-server -n argocd 5000:443" &>/dev/null

# Delete ArgoCD resources
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Delete namespaces created
kubectl delete namespace dev
kubectl delete namespace argocd

# Delete the k3d cluster
k3d cluster delete cluster

# Confirmation message
echo "Cleanup complete. All resources removed."
