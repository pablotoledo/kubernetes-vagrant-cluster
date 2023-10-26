# List of required plugins for this Vagrant setup
required_plugins = %w[vagrant-reload]
needs_restart = false

# Install any missing plugins from the required list
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system "vagrant plugin install #{plugin}"
    needs_restart = true
  end
end

# If any plugins were installed, prompt the user to rerun the command
if needs_restart
  puts "Plugins installed. Please run the command again."
  exit
end

# Vagrant configuration starts here
Vagrant.configure("2") do |config|
  
  # Define the box to be used and its settings
  # TODO: rocky linux and remove dnf
  config.vm.box = "fedora/38-cloud-base"
  # Define the synced folder from the host to the guest
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # General settings for the VirtualBox provider
  config.vm.provider "virtualbox" do |v|
    v.default_nic_type = "82540EM"
    v.linked_clone = true
  end

  # More specific settings for the VirtualBox provider 
  config.vm.provider :virtualbox do |vb|
    vb.memory = "1024"   # Assign 1GB RAM to the VM
    vb.cpus = 2   # Assign 2 CPUs to the VM
    vb.default_nic_type = "82540EM"
    # Allow the creation of symbolic links in shared folders
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    # Specify the VRDE (VirtualBox Remote Desktop Extension) port range
    vb.customize ["modifyvm", :id, "--vrdeport", "10001-20000"]
    # Set VRDE IP address binding
    vb.customize ["modifyvm", :id, "--vrdeaddress", "0.0.0.0"]
    # Allow bidirectional clipboard access between host and VM
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end

  # Master node configuration
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    # Network settings for the master node
    master.vm.network "public_network", bridge: "Realtek PCIe GbE Family Controller", ip: "192.168.0.70"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"   # Assign 8GB RAM to the master VM
      vb.cpus = 4   # Assign 4 CPUs to the master VM
      vb.name = "k8s-master"
    end
    # Provision the VM using shell scripts and other provisioning methods
    master.vm.provision "shell", path: "node.sh", args: ["k8s-master", "192.168.0.70"]
    master.vm.provision :reload
    master.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 8.8.8.8" >> /etc/resolv.conf
      chattr +i /etc/resolv.conf
    SHELL
    master.vm.provision "shell", path: "master.sh"
  end

  # Worker nodes configuration
  (1..2).each do |i|
    config.vm.define "k8s-node-#{i}" do |node|
      node.vm.hostname = "k8s-node-#{i}"
      # Network settings for the worker nodes
      node.vm.network "public_network", bridge: "Realtek 8812BU Wireless LAN 802.11ac USB NIC", ip: "192.168.0.#{70 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "12288"   # Assign 12GB RAM to each worker VM
        vb.cpus = 8   # Assign 8 CPUs to each worker VM
        vb.name = "k8s-node-#{i}"
      end
      # Provision the VM using shell scripts
      node.vm.provision "shell", path: "node.sh", args: ["k8s-node-#{i}", "192.168.0.#{70 + i}"]
      node.vm.provision :reload
      node.vm.provision "shell", path: "node-nfs.sh"
      node.vm.provision "shell", inline: <<-SHELL
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
        chattr +i /etc/resolv.conf
      SHELL
      node.vm.provision :reload
    end
  end
end
