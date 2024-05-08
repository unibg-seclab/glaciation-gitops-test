#!/bin/bash

# By setting the KUBECONFIG environment variable it is possible to run the
# setup against different kubernetes environments

echo "[*] Install ArgoCD"
helm repo add argo https://argoproj.github.io/argo-helm
helm install \
    --create-namespace \
    --namespace argocd \
    --set configs.repositories[0].type=git \
    --set configs.repositories[0].url=https://github.com/unibg-seclab/glaciation-gitops-test.git \
    --set server.service.type=NodePort \
    --values values/argo-cd-values.yaml \
    my-release argo/argo-cd

echo -e '\nWaiting for the rollout of the service...'
kubectl -n argocd rollout status deploy/my-release-argocd-applicationset-controller
kubectl -n argocd rollout status deploy/my-release-argocd-dex-server
kubectl -n argocd rollout status deploy/my-release-argocd-notifications-controller
kubectl -n argocd rollout status deploy/my-release-argocd-redis
kubectl -n argocd rollout status deploy/my-release-argocd-repo-server
kubectl -n argocd rollout status deploy/my-release-argocd-server
kubectl -n argocd rollout status sts/my-release-argocd-application-controller

NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
NODE_PORT=$(kubectl -n argocd get services my-release-argocd-server -o jsonpath="{.spec.ports[0].nodePort}")
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "\nServing ArgoCD at http://$NODE_IP:$NODE_PORT"
echo "Credentials: user=admin, password=$PASSWORD"

echo -e "\n[*] Install ArgoCD"
kubectl create -f bootstrap.yaml
