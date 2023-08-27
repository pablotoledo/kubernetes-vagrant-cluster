# Kubernetes Cluster Setup with Vagrant

This repository provides the necessary tools and scripts to set up a Kubernetes cluster on-premise using Vagrant. Designed for educational purposes, it offers insights into the configuration and deployment of a Kubernetes cluster in a local environment.

## Prerequisites
- VirtualBox installed on your machine.
- Vagrant installed on your machine.

## Overview
The setup scripts have been hardcoded to use a specific network IP range and a particular network device. Before you begin, you will need to adjust these settings to match your local environment.

### Adaptation Steps:
1. **Network Device Adjustment**:
    - Open a terminal.
    - Use the command `vboxmanage list bridgedifs` to view available bridged network interfaces on your machine.
    - From the list, identify the `Name` of the network device you wish to use.
    - Replace the hardcoded network device name (`"Realtek 8812BU Wireless LAN 802.11ac USB NIC"`) in both the `Vagrantfile` and `node.sh` with your identified network device name.

2. **IP Range Configuration**:
    - Determine the IP range of your local network. Typically, for home networks, the range is something like `192.168.0.0/24` or `192.168.1.0/24`.
    - Identify a subset of IP addresses within this range that are free to use.
    - Update the hardcoded IP addresses in the `Vagrantfile` and `node.sh` to match the subset of free IP addresses you've identified.

## Architecture Overview

The proposed Kubernetes cluster setup comprises:

1. **Master Node (k8s-master)**:
    - The control plane node that manages the Kubernetes cluster.
    - Configured with more resources to effectively manage the cluster operations.
    - IP: `192.168.0.70`
    - NFS Server installed and configured to share `/mnt/nfs/data` folder.

2. **Worker Nodes (k8s-node-1, k8s-node-2)**:
    - Nodes where your applications will run.
    - Scalable configuration: By default, two worker nodes are provisioned, but the setup can be easily adjusted to spawn more or fewer nodes as needed.
    - IPs: Starting from `192.168.0.71` and incrementing for each subsequent worker node.
    - Integrated with the NFS Server in the master node.

### Operating System
The nodes in this cluster are provisioned using **Fedora 38**. Fedora was chosen for its robustness, up-to-date packages, and compatibility with Kubernetes.

### Kubernetes Setup
- **Kubernetes**: An open-source container orchestration platform. It automates the deployment, scaling, and operations of application containers across clusters of hosts.
    - Installed using the package manager `dnf` and configured via `kubeadm`.
    - The `kubeadm` tool is utilized for bootstrapping a best-practice Kubernetes cluster.
    - The control-plane node is initiated with `kubeadm init`.

- **Calico**: A network solution for Kubernetes that provides network connectivity for pods and security policies to control communication between pods.
    - Calico uses a pure IP networking fabric to deliver high-performance Kubernetes networking and network policy.
    - Installed via its manifest which is fetched directly from the official Calico GitHub repository.

### Why this Configuration?

1. **Fedora 38**: Provides a stable environment with a modern set of tools, making it an excellent choice for Kubernetes deployment.
2. **Kubernetes**: A leader in container orchestration, ensuring applications run smoothly, scaling in and out as required.
3. **Calico**: Provides not only network connectivity for pods but also an additional layer of security, making sure your cluster's communication remains isolated and secure.


## Usage
1. Clone the repository.
2. Navigate to the repository directory.
3. Modify the `Vagrantfile` and `node.sh` based on the adaptation steps mentioned above.
4. Run `vagrant up` to start and provision the virtual machines.
5. Once the VMs are up and running, your Kubernetes cluster should be operational.

## Node Joining Procedure

To join a node to the Kubernetes cluster, you'll use the `kubeadm join` command. The general structure of the command is as follows:

```bash
kubeadm join [MASTER_IP]:[PORT] --token [TOKEN] --discovery-token-ca-cert-hash [HASH] --apiserver-advertise-address=[NODE_IP]
```

For example, if you wish to join `k8s-node-1` to the cluster, you'll run the following command on the node:

```bash
kubeadm join 192.168.0.70:6443 --token ye7mrv.wb3y5tvfml5h28i6 --discovery-token-ca-cert-hash sha256:54b4d8feb39efdad99a55c365b3cd6be3e746f15230736e4d73f6784bd875ce7 --apiserver-advertise-address=192.168.0.71
```

Important: When specifying the `--apiserver-advertise-address` flag, it's essential to declare the domestic network IP assigned to the node. Failing to do so might cause the node to use the eth0 network, which Vagrant employs. This oversight can lead to issues on the master node because eth0 has the same IP on all machines. As a result, the master might refer to itself, causing connectivity issues.


## Note
Please remember, this setup is designed for educational purposes. It's crucial to understand each script's workings and modify them according to your specific requirements before deploying in any other environment.

## Contributions
Feel free to fork this repository, make changes, and submit pull requests. Any feedback or suggestions are welcome!

## License
This project is open-sourced under the MIT License.
