Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true

  config.vm.box = "bento/ubuntu-16.04"
  config.vm.synced_folder "apps", "/home/vagrant/apps"

  # copy templates for provision
  config.vm.provision "file", source: "scripts/templates/zshrc", destination: "/tmp/provision/zshrc"
  config.vm.provision "file", source: "scripts/templates/gems/gemrc", destination: "/tmp/provision/gemrc"
  config.vm.provision "file", source: "scripts/templates/gems/bundle-config", destination: "/tmp/provision/bundle"
  config.vm.provision "file", source: "scripts/templates/nginx/nginx.conf", destination: "/tmp/provision/nginx.conf"

  # system provision
  config.vm.provision "shell", path: "scripts/root-provision.sh"

  # vagrant user provision
  config.vm.provision "shell", path: "scripts/vagrant-provision.sh", privileged: false

  # configure private network ip
  config.vm.network :private_network, ip: "192.168.68.8"
end
