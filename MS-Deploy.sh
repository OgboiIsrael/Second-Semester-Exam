#!/bin/bash

###################################################################################################################

# Variable declarations

###################################################################################################################

VFile="Vagrantfile"
M_VM="master"
S_VM="slave"
MVM_IP="192.168.20.2"
SVM_IP="192.168.20.3"
DB_USER='altschool'
USER_PASS='altschool'

###################################################################################################################

# Configuration in vagrantfile for master and slave machine

###################################################################################################################

cat <<EOT >> $VFile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	config.vm.network "forwarded_port", guest: 80, host: 4080, host_ip: "127.0.0.1"

	config.vm.define "$M_VM" do |$M_VM|
		$M_VM.vm.hostname = "$M_VM"
		$M_VM.vm.box = "ubuntu/focal64"
		$M_VM.vm.network "private_network", ip: "$MVM_IP"

		$M_VM.vm.provision "shell", inline: <<-SHELL
			sudo apt-get update && sudo apt-get upgrade -y
			sudo apt install sshpass-y
			sudo apt-get install -y avahi-daemon libnss-mdns
			sudo apt install ansible -y
			sudo su
			chmod 664 /etc/ssh/sshd_config
			sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
			sudo systemctl restart ssh
			echo "Creating new user - altschool and granting root privileges..."
			sudo useradd -m -s /bin/bash -G root,sudo $DB_USER
			echo "$DB_USER:$USER_PASS" | sudo chpasswd
		SHELL
	end

	config.vm.define "$S_VM" do |$S_VM|
		$S_VM.vm.hostname = "$S_VM"
		$S_VM.vm.box = "ubuntu/focal64"
		$S_VM.vm.network "private_network", ip: "$SVM_IP"

		$S_VM.vm.provision "shell", inline: <<-SHELL
			sudo apt-get update && sudo apt-get upgrade -y
			sudo apt install sshpass-y
			sudo apt-get install -y avahi-daemon libnss-mdns
			sudo su
			chmod 664 /etc/ssh/sshd_config
			sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
			sudo systemctl restart ssh
			echo "Creating new user - altschool and granting root privileges..."
			sudo useradd -m -s /bin/bash -G root,sudo $DB_USER
			echo "$DB_USER:$USER_PASS" | sudo chpasswd
		SHELL
	end

	config.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
		vb.cpus = "2"
	end
end
EOT


###################################################################################################################

# Run vagrantfile

###################################################################################################################

vagrant up