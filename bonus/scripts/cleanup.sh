#!/bin/bash
set -e

echo "Checking for stuck resources..."
kubectl get all -n gitlab || true

echo "Uninstalling Helm release first..."
helm uninstall gitlab -n gitlab || true

echo "Waiting for pods termination..."
kubectl wait --for=delete pod --all -n gitlab --timeout=300s || true

echo "Removing configmaps..."
kubectl delete configmap -n gitlab --all || true

echo "Checking finalizers..."
kubectl get namespace gitlab -o json | grep finalizers || true

echo "Now deleting namespace..."
kubectl delete namespace gitlab --force || true

echo "Waiting for namespace deletion..."
kubectl wait --for=delete namespace/gitlab --timeout=300s || true

echo "Finally removing Helm repository..."
helm repo remove gitlab || true

echo "Cleanup completed"