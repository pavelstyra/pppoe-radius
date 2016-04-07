$script = <<SHELL
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime
apt-get update
apt-get -y install unzip git tcpdump
SHELL

Vagrant.configure(2) do |config|
  config.vm.define "server" do |server|
    server.vm.box = "debian/contrib-jessie64"
    server.vm.hostname = "pppoe-server"
    server.vm.network "private_network", ip: "172.16.0.10"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
    server.vm.provision "shell", inline: $script
    server.vm.provision "shell", path: "server.sh"
    server.vm.provision "shell", path: "radius.sh"
  end

  config.vm.define "client1" do |client|
    client.vm.box = "debian/contrib-jessie64"
    client.vm.hostname = "pppoe-client1"
    client.vm.network "private_network", ip: "172.16.0.20"
    client.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
    client.vm.provision "shell", inline: $script
    client.vm.provision "shell", path: "client1.sh"
  end

  config.vm.define "client2" do |client|
    client.vm.box = "debian/contrib-jessie64"
    client.vm.hostname = "pppoe-client2"
    client.vm.network "private_network", ip: "172.16.0.30"
    client.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
    client.vm.provision "shell", inline: $script
    client.vm.provision "shell", path: "client2.sh"
  end
end
