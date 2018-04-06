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

    $script_install_software = <<SCRIPT
    sudo yum upgrade -y
    sudo yum install -y docker vim nano
SCRIPT

    config.vm.define "controller" do |h|
        h.vm.box = "centos/7"
        h.vm.hostname = "kubepoc.int"
        h.vm.network "private_network", ip: "192.168.40.10"
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "kube-poc"
        end
        h.vm.provision "shell", inline: $script_install_software 
    end
    

end