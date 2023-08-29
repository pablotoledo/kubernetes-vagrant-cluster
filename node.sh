#!/bin/bash

# This script is inspired by the documentation at https://www.server-world.info/en/note?os=Fedora_38&p=kubernetes
set -x  # Enable debugging mode.

# Assign hostname and IP variables from the arguments passed to the script.
HOSTNAME=$1
IP=$2

# Configure the network with the appropriate IP address.
sudo nmcli con mod "Wired connection 2" ipv4.addresses ${IP}/24
sudo nmcli con mod "Wired connection 2" ipv4.method manual
sudo nmcli con up "Wired connection 2"

# Disable SELinux and configure the firewall.
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Upgrade & Clean package cache.
sudo dnf update -y
dnf clean packages

# Set the system hostname.
hostnamectl set-hostname ${HOSTNAME}

# Configure system parameters required for Kubernetes and CRI.
cat > /etc/sysctl.d/99-k8s-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

echo -e "overlay\\nbr_netfilter" > /etc/modules-load.d/k8s.conf
dnf install -y iptables-legacy
alternatives --config iptables <<EOF
2
EOF

# Disable swap memory.
touch /etc/systemd/zram-generator.conf
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Install required packages and set them up.
dnf module install -y cri-o:1.25/default
systemctl enable --now crio
dnf install -y wget kubernetes-kubeadm kubernetes-node kubernetes-client cri-tools iproute-tc container-selinux

# Update kubelet configuration.
sed -i 's/^KUBELET_ADDRESS=.*/KUBELET_ADDRESS="--address=0.0.0.0"/' /etc/kubernetes/kubelet
sed -i 's/^#KUBELET_PORT=.*/KUBELET_PORT="--port=10250"/' /etc/kubernetes/kubelet
sed -i "s/^KUBELET_HOSTNAME=.*/KUBELET_HOSTNAME=\"--hostname-override=${HOSTNAME}\"/" /etc/kubernetes/kubelet
sed -i '/KUBELET_EXTRA_ARGS=/d' /etc/systemd/system/kubelet.service.d/kubeadm.conf
sed -i "/\[Service\]/a Environment=\"KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint=unix:///var/run/crio/crio.sock --node-ip=${IP}\"" /etc/systemd/system/kubelet.service.d/kubeadm.conf

# Disable the firewalld service.
systemctl disable --now firewalld

# Disable systemd-resolved and configure DNS.
systemctl disable --now systemd-resolved
sed -i 's/^dns=.*/dns=default/' /etc/NetworkManager/NetworkManager.conf
unlink /etc/resolv.conf
touch /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Initialize Kubernetes.
sleep 20  # Pause for 20 seconds.
systemctl enable kubelet

# Enable SSH password authentication.
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Restart the SSH service.
systemctl restart sshd
