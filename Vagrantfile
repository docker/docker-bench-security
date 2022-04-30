Vagrant.configure("2") do |config|
  config.vbguest.installer_options = { allow_kernel_upgrade: true }
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
  end

  config.vm.define "jammy" do |jammy|
    jammy.ssh.extra_args = ["-o","ConnectTimeout=600"]
    jammy.ssh.insert_key = true
    jammy.vm.boot_timeout = 600
    jammy.vm.box = "ubuntu/jammy64"
    jammy.vm.hostname = "jammy"
    jammy.vm.provision "shell",
      inline: "apt-get update && curl -sSL get.docker.com | sh && addgroup vagrant docker"
  end
end
