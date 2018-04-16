# -*- mode: ruby -*-
# vi: set ft=ruby :

# README
#
# Getting Started:
# 1. vagrant plugin install vagrant-hostmanager
# 2. vagrant plugin install vagrant-vbguest
# 3. vagrant up
#
# This should put you at the control host
#  with access, by name, to other vms - 
Vagrant.configure("2") do |config|
    
    config.hostmanager.enabled = true

    config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: false,
    rsync__exclude: ".git/"

    $script_install_common_software = <<SCRIPT
    sudo yum upgrade -y
    sudo yum install -y go git wget docker
    sudo systemctl enable docker 
    sudo systemctl start docker
    sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
    sudo setenforce 0
    sudo swapoff -a 
    sudo rm /etc/fstab
    sudo yum install -y kubelet kubeadm kubectl
    sudo systemctl enable kubelet 
    sudo systemctl start kubelet
SCRIPT

    $script_setup_master = <<SCRIPT
    sudo go get github.com/kubernetes-incubator/cri-tools/cmd/crictl
    sudo bash -c "echo net.bridge.bridge-nf-call-ip6tables = 1 >> /etc/sysctl.conf"
    sudo bash -c "echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf"
    sudo sysctl --system
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.40.10 
    sudo kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
    #sudo kubeadm token list | sed -n '2p' | awk 'BEGIN { FS=" " } { print $1 }' > /vagrant/token.log
    sudo kubeadm token create --print-join-command >> /vagrant/workerjoin.log
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
SCRIPT

    $script_setup_worker = <<SCRIPT
    sudo bash /vagrant/workerjoin.log
SCRIPT

    $script_generate_ssh_key = <<SCRIPT
    echo Updateing credentials
    if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
    fi
        cp /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub

        cat << 'SSHEOF' > /home/vagrant/.ssh/config
    Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
SSHEOF
        sudo chown -R vagrant:vagrant /home/vagrant/.ssh/
SCRIPT

    $script_solve_network_issues = <<SCRIPT
    # https://github.com/kubernetes/kubernetes/issues/62256
    sudo echo "nameserver 8.8.8.8" > /etc/resolv.conf

SCRIPT

    $script_copy_key = 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'

    config.vm.define "k8s-master" do |h|
        h.vm.box = "centos/7"
        h.vm.hostname = "master.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.10", auto_config: true
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-master"
        end
        h.vm.provision "shell", inline: $script_generate_ssh_key 
        h.vm.provision "shell", inline: $script_install_common_software
        h.vm.provision "shell", inline: $script_solve_network_issues 
        #h.vm.provision "shell", inline: $script_setup_master
    end

    config.vm.define "k8s-worker1" do |h|
        h.vm.box = "centos/7"
        h.vm.hostname = "worker1.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.11", auto_config: true
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-worker1"
        end
        h.vm.provision "shell", inline: $script_copy_key
        h.vm.provision "shell", inline: $script_install_common_software 
        h.vm.provision "shell", inline: $script_solve_network_issues 
        #h.vm.provision "shell", inline: $script_setup_worker
    end

    config.vm.define "k8s-worker2" do |h|
        h.vm.box = "centos/7"
        h.vm.hostname = "worker2.k8s.int"
        h.vm.network "private_network", ip: "192.168.40.12", auto_config: true
        h.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "4096"]
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.name = "k8s-worker2"
        end
        h.vm.provision "shell", inline: $script_copy_key
        h.vm.provision "shell", inline: $script_install_common_software 
        h.vm.provision "shell", inline: $script_solve_network_issues 
        #h.vm.provision "shell", inline: $script_setup_worker
    end
    

end