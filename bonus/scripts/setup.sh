#!/bin/bash

GITLAB_DOMAIN="jihagukdejeok.ai"

# Check if the Kubernetes API server is reachable
if ! kubectl cluster-info &>/dev/null; then
	echo "Error: Kubernetes cluster is not running or accessible."
	exit 1
fi

#Install helm (a package manager for kubernetes)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Add the GitLab Helm chart repository and update
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Create the new namespace for GitLab
kubectl create namespace gitlab

# Install GitLab
curl -fsSL -o values-minikube-minimum.yaml https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml
helm repo add gitlab https://charts.gitlab.io/
helm install gitlab gitlab/gitlab --namespace gitlab \
	--set global.edition=ce \
	--version 7.9.2 \
	--set global.hosts.domain=$GITLAB_DOMAIN \
	--set global.hosts.externalIP=0.0.0.0 \
	--set global.hosts.https=false \
	-f values-minikube-minimum.yaml
rm values-minikube-minimum.yaml

if ! grep -q "127.0.0.1 $GITLAB_DOMAIN" /etc/hosts; then
	echo "Adding $GITLAB_DOMAIN to your /etc/hosts"
	echo -e "127.0.0.1 $GITLAB_DOMAIN" | sudo tee -a /etc/hosts >/dev/null
else
	echo "$GITLAB_DOMAIN already exists in /etc/hosts"
fi

echo "Waiting for gitlab service to get ready"
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=800s

echo "Gitlab is running"
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8080:8181