#!/bin/bash

NAME_OF_BOX=rails-production-server2
NET_INTERFACE=wlan0
IP=""
DEFAULT_NAME_OF_HOST=vagrant-ubuntu-trusty-64

getip () {
	IP=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`
}

case $1 in
start)
echo "Start server"
vboxmanage startvm "${NAME_OF_BOX}" --type headless
;;
stop)
echo "Stop server"
getip
ssh vagrant@$IP "sudo poweroff"
;;
ip)
echo "Get IP"
getip
echo $IP
;;
################################################################################################
createvm)
echo "Make server"
if [ ! -f ../ubuntubox/virtualbox.box ]; then
    wget -P ../ubuntubox/ https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20151117.0.0/providers/virtualbox.box
    tar xvf ../ubuntubox/virtualbox.box -C ../ubuntubox/
    rm ../ubuntubox/virtualbox.box
fi

count=`vboxmanage list vms | grep "\"${NAME_OF_BOX}\"" | wc -l`

if [ $count -ne 0 ]
then
	echo "Maszyna wirtualna serwera już istnieje"
else
	#http://nakkaya.com/2012/08/30/create-manage-virtualBox-vms-from-the-command-line/
	echo "Tworzę maszynę wirtualną serwera"
	vboxmanage import ../ubuntubox/box.ovf --vsys 0 --vmname "${NAME_OF_BOX}";
	#future use: for Host-only networking http://makahiki.readthedocs.org/en/latest/installation-makahiki-vagrant-configuration-vagrant.html
	vboxmanage modifyvm "${NAME_OF_BOX}" --nic1 bridged --bridgeadapter1 ${NET_INTERFACE}
	vboxmanage modifyvm "${NAME_OF_BOX}" --memory 1024
	vboxmanage modifyvm "${NAME_OF_BOX}" --cpus 2
	#vboxmanage modifyvm "${NAME_OF_BOX}" --macaddress1 08002723A640
fi
;;
################################################################################################
provision1)
echo "Provision: stage 1 (pass: 'vagrant')"

getip
ssh-copy-id vagrant@$IP

ssh vagrant@$IP /bin/bash <<-EOF
echo "Europe/Warsaw" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install build-essential

# potrzebne dla kompilacji ruby
sudo aptitude -y install libffi-dev libreadline-dev

sudo aptitude -y install unattended-upgrades mc

#tylko gdy nie działa apt-add-repository - wersja Ubuntu Server ponoć
#sudo aptitude -y install software-properties-common

sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo aptitude update
sudo aptitude -y upgrade

sudo aptitude install -y ruby2.3 ruby2.3-dev
sudo aptitude install -y ruby-switch

sudo ruby-switch --set ruby2.3

#Postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install postgresql-9.4 postgresql-9.4-postgis-2.1 postgresql-contrib


# Install Phusion's PGP key to verify packages
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

# Add HTTPS support to APT
sudo aptitude -y install apt-transport-https

# Add the passenger repository
sudo sh -c 'echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list'
#sudo chown root: /etc/apt/sources.list.d/passenger.list
#sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo aptitude update

# Install nginx and passenger
sudo aptitude -y install nginx-full passenger

echo "gem: --no-document" > ~/.gemrc

sudo aptitude -y install git-core build-essential
sudo aptitude -y install libsqlite3-dev sqlite3

#wymagane przez rails
sudo aptitude -y install zlib1g-dev libpq-dev

sudo gem install bundler
EOF

ssh -t vagrant@$IP "sudo sed -i -e 's/${NAME_OF_HOST}/${NAME_OF_BOX}/g' /etc/hostname"
ssh -t vagrant@$IP "sudo poweroff"
echo "Server poweroff"
;;
################################################################################################
provision2)
getip

NEWUSER=deploy

ssh vagrant@$IP /bin/bash <<-EOF
sudo adduser --disabled-password --gecos '' $NEWUSER
sudo adduser ${NEWUSER} ${NEWUSER}
sudo bash -c 'echo "${NEWUSER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NEWUSER}'
sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
EOF
cat ~/.ssh/id_rsa.pub | ssh vagrant@$IP "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"

#ustawienia nginx+passenger
scp provision/nginx.conf ${NEWUSER}@$IP:~
scp provision/production ${NEWUSER}@$IP:~
scp provision/staging ${NEWUSER}@$IP:~
#backup bazy
scp provision/backup_db.sh ${NEWUSER}@$IP:~

PASS=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`

ssh ${NEWUSER}@$IP /bin/bash <<-EOF
sudo service nginx stop
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo cp production /etc/nginx/sites-available/production
sudo cp staging /etc/nginx/sites-available/staging
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/production /etc/nginx/sites-enabled/production
sudo ln -s /etc/nginx/sites-available/staging /etc/nginx/sites-enabled/staging
sudo service nginx start

mkdir dbbackup
chmod a+x ~/backup_db.sh
echo "1  0   * * *   deploy    /home/deploy/dbbackup.sh" | sudo tee --append /etc/crontab > /dev/null

## postgres 

sudo -u postgres psql -c "CREATE USER $NEWUSER WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;"

echo "export DATABASE_USER_PASSWORD=$PASS" >> ~/.profile
echo "export RAILS_ENV=production" >> ~/.profile

echo "export SECRET_KEY_BASE=`ruby -e "require 'securerandom'; print SecureRandom.hex(64);"`" >> ~/.profile
EOF

NEWUSER=staging

ssh vagrant@$IP /bin/bash <<-EOF
sudo adduser --disabled-password --gecos '' $NEWUSER
sudo adduser ${NEWUSER} ${NEWUSER}
sudo bash -c 'echo "${NEWUSER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NEWUSER}'
sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
EOF
cat ~/.ssh/id_rsa.pub | ssh vagrant@$IP "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"

scp provision/import_db.sh ${NEWUSER}@$IP:~

PASS=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`

ssh ${NEWUSER}@$IP /bin/bash <<-EOF

sudo -u postgres psql -c "CREATE USER $NEWUSER WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;"

echo "export DATABASE_USER_PASSWORD=$PASS" >> ~/.profile
echo "export RAILS_ENV=staging" >> ~/.profile

echo "export SECRET_KEY_BASE=`ruby -e "require 'securerandom'; print SecureRandom.hex(64);"`" >> ~/.profile

cat ~/.ssh/id_rsa.pub | sudo -H -u deploy tee --append /home/deploy/.ssh/authorized_keys > /dev/null

chmod a+x ~/import_db.sh
EOF
ssh -t vagrant@$IP "sudo poweroff"
;;
################################################################################################
test1)
getip
NEWUSER=staging
ssh ${NEWUSER}@$IP /bin/bash <<-EOF
USER1=`whoami`
sudo -u postgres echo "CREATE USER $USER1 WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;" > ~/toja2.txt

echo "export SECRET_KEY_BASE=`ruby -e "require 'securerandom'; print SecureRandom.hex(64);"`" > ~/secret.txt
EOF

;;
*)
echo "Unknown option"
esac


