# -*- mode: ruby -*-
# vi: set ft=ruby :

# README
#
# Getting Started:
# 1. vagrant plugin install vagrant-hostmanager
#       If you are running this Vagrantfile behind a corporate proxy: 
#           vagrant plugin install vagrant-proxyconf
# 2. vagrant up
# 3. vagrant ssh
#
# This should put you at the control host
#  with access, by name, to other vms
Vagrant.configure("2") do |config|
    
    config.hostmanager.enabled = true

    #config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: false,
    #rsync__exclude: ".git/"

    $script_install_common_software = <<SCRIPT
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y docker.io vim nano
    sudo apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
SCRIPT

    config.vm.define "k8s-master" do |h|
        h.vm.box = "ubuntu/xenial64"
        h.vm.hostname = "master.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.10"
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-master"
        end
        h.vm.provision "shell", inline: $script_install_common_software 
    end

    config.vm.define "k8s-worker1" do |h|
        h.vm.box = "ubuntu/xenial64"
        h.vm.hostname = "worker1.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.11"
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-worker1"
        end
        h.vm.provision "shell", inline: $script_install_common_software 
    end

    config.vm.define "k8s-worker2" do |h|
        h.vm.box = "ubuntu/xenial64"
        h.vm.hostname = "worker2.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.12"
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-worker2"
        end
        h.vm.provision "shell", inline: $script_install_common_software 
    end
    

end