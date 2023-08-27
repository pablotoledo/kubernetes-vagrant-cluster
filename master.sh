#!/bin/bash

# Enable debugging mode. This prints commands to stdout before executing them.
set -x

# === Init kubeadm Section ===
echo "Init kubeadm Section"

# Wait for 30 seconds. This might be needed to allow certain services to be ready or to ensure previous operations have completed.
sleep 30

# Initialize the Kubernetes control plane. 
# - The `--control-plane-endpoint` sets the control plane's endpoint IP.
# - The `--pod-network-cidr` determines the IP range pods should use.
# - The `--cri-socket` sets the CRI (Container Runtime Interface) socket path, which is for CRIO in this case.
# - The `--apiserver-advertise-address` specifies the IP address on which to advertise the kube-apiserver to members of the cluster.
kubeadm init --control-plane-endpoint=192.168.0.70 --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/crio/crio.sock --apiserver-advertise-address=192.168.0.70

# Wait for another 30 seconds.
sleep 30

# Create or ensure the existence of the .kube directory within the home directory.
mkdir -p $HOME/.kube

# Copy the Kubernetes admin configuration to the user's kube config directory.
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 

# Change the ownership of the kube config to the current user and group.
chown $(id -u):$(id -g) $HOME/.kube/config 

# Download the Calico CNI (Container Network Interface) manifest file.
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Apply the Calico CNI to the Kubernetes cluster.
kubectl apply -f calico.yaml 

# Wait for another 30 seconds.
sleep 30

# Display the current state of the nodes in the Kubernetes cluster.
kubectl get nodes -o wide

# Wait for another minute.
sleep 60

# Display the current state of all pods across all namespaces in the Kubernetes cluster.
kubectl get pods -A -o wide

# Prepare the 'vagrant' user to use kubectl by copying over the Kubernetes admin configuration.
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Persistent Volumes using NFS
# Installing NFS
dnf install -y nfs-utils

# Create the directory that will be shared with the worker nodes.
mkdir -p /nfs/data

# Granting permissions to the folder
chmod 777 /nfs/data

# Add NFS configuration to /etc/exports
echo "/nfs/data    *(rw,sync,no_subtree_check)" >> /etc/exports

# Enable NFS service
systemctl enable nfs-server
systemctl start nfs-server

# Apply NFS configuration
exportfs -ra
