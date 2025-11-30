#!/bin/bash
set -e

echo "Setting Docker env to current Kubernetes cluster (minikube)..."
eval "$(minikube -p minikube docker-env)"

echo "Building local Docker images inside minikube..."
docker build -t backend ../backend
docker build -t transactions ../transactions
docker build -t studentportfolio ../studentportfolio

echo "Images in minikube:"
docker images | grep -E "backend|transactions|studentportfolio" || true

echo "Applying Kubernetes manifests..."
kubectl apply -f .

echo "Restarting deployments to pick up fresh images..."
kubectl rollout restart deployment backend
kubectl rollout restart deployment transactions
kubectl rollout restart deployment studentportfolio
kubectl rollout restart deployment nginx

echo "Current pods:"
kubectl get pods -o wide
