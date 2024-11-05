#!/bin/bash

# Minikube Installation
echo "Installing Minikube..."
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod 755 /usr/local/bin/minikube
minikube version

# Docker Installation
echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker

# Kubectl Installation
echo "Installing Kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
kubectl version --client

# Docker for non-root user setup
echo "Setting up Docker for non-root user..."
sudo usermod -aG docker $USER && newgrp docker

# Minikube start
echo "Starting Minikube..."
minikube start --driver=docker --kubernetes-version=v1.30.0

# Helm Installation
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh
helm version

#Add Helm Stable Charts for Your Local Client
helm repo add stable https://charts.helm.sh/stable

#Add Prometheus Helm Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

#Create Prometheus Namespace and list Namespaces
kubectl create namespace prometheus

#Install Prometheus using Helm
helm install stable prometheus-community/kube-prometheus-stack -n prometheus

#Expose Prometheus and Grafana to the external world through Node Port
kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc stable-grafana -n prometheus -p '{"spec": {"type": "NodePort"}}'

#Get a password for grafana
echo "Default Username: admin"
echo "Generating password"
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

echo "Installation and setup complete!"
