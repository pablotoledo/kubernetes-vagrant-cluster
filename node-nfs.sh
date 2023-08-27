#!/bin/bash

# Persistent Volumes using NFS
# Installing NFS
dnf install -y nfs-utils

# Create the directory that will be shared with the worker nodes.
mkdir -p /mnt/nfs/data

# Mount the NFS Volume
mount -t nfs 192.168.0.70:/nfs/data /mnt/nfs/data

# Adding configuration to /etc/fstab
echo "192.168.0.70:/nfs/data    /mnt/nfs/data   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab