VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = "dpuknode"

  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network "private_network", ip: "192.168.50.50"
  config.vm.provider "virtualbox" do |v|
    v.name = "dpuknode"
  	v.memory = 2048
  	v.cpus = 1
  end
  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 1
  end
  config.vm.provision "shell", path: "provision.sh"

end
