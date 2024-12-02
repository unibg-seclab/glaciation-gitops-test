#!/bin/bash

echo "[*] Setup Minikube cluster with 4 nodes"
minikube start --nodes=4

echo -e "\n[*] Deploy NGINX Ingress Controller"
minikube addons enable ingress
