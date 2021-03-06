#!/bin/bash

set -e

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev

# Install necessary libraries for guest additions and Vagrant NFS Share
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common python-pip python-dev git

# Install necessary dependencies
sudo apt-get -y -q install curl wget git tmux xvfb vim

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers


# install guest additions
mkdir /mnt/iso
mount -t iso9660 VBoxGuestAdditions_*.iso /mnt/iso/
/mnt/iso/VBoxLinuxAdditions.run || /bin/true
umount /mnt/iso

#Install Redis
#sudo apt-get -y -q install libjemalloc1
#wget -q http://d7jrzzvab3wte.cloudfront.net/checkbot/deb/redis-server_2.6.13-1_amd64.deb
#sha1sum redis-server_2.6.13-1_amd64.deb | grep 'ab50cf037fd63e160946f8946b6d318cdf11800d'
#dpkg -i redis-server_2.6.13-1_amd64.deb
#rm redis-server_2.6.13-1_amd64.deb

# Install required libraries for RVM and Ruby
#sudo apt-get -y -q install gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev libxml2-dev libxslt-dev libxml2


# Install Postgresql
#sudo apt-get -y -q install postgresql libpq-dev postgresql-contrib

# Set Password to test for user postgres
#sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'test';"

# Install ansible
mkdir /etc/ansible
chown vagrant:vagrant -R /etc/ansible
sudo pip install ansible==1.9.4
sudo ansible-galaxy install DecibelInsight.python
sudo ansible-playbook /etc/ansible/roles/DecibelInsight.python/python.yml -c local -i 'localhost, '
sudo rm -rf /home/vagrant/.ansible
/etc/init.d/apparmor stop
sudo update-rc.d -f apparmor remove
sudo apt-get --purge remove -y apparmor apparmor-utils libapparmor-perl libapparmor1
