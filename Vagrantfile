Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true

  config.vm.box = "bento/ubuntu-16.04"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4000
  end

  # Configure shared folder
  # {
  #   "../apps-dir" => "/home/vagrant/apps"
  # }.each do |src, dest|
  #   config.vm.synced_folder src, dest
  # end

  # copy templates for provision
  {
    "scripts/templates/zshrc" => "/tmp/provision/zshrc",
    "scripts/templates/gems/gemrc" => "/tmp/provision/gemrc",
    "scripts/templates/gems/bundle-config" => "/tmp/provision/bundle",
    "scripts/templates/nginx/nginx.conf" => "/tmp/provision/nginx.conf",
    "scripts/templates/Xvfb.service" => "/tmp/provision/Xvfb.service",
  }.each do |src, dest|
    config.vm.provision "file", source: src, destination: dest
  end

  # system provision
  config.vm.provision "shell", path: "scripts/root-provision.sh"

  # vagrant user provision
  config.vm.provision "shell", path: "scripts/vagrant-provision.sh", privileged: false

  # configure private network ip
  config.vm.network :private_network, ip: "192.168.68.8"
end
