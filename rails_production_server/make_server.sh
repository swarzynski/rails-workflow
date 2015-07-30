#!/bin/bash

NAME_OF_BOX=rails-production-server

if [ ! -f ../ubuntubox/box.ovf ]; then
    wget -P ../ubuntubox/ https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/20150609.0.10/providers/virtualbox.box
    tar xvf ../ubuntubox/virtualbox.box -C ../ubuntubox/
    rm ../ubuntubox/virtualbox.box
fi

count=`vboxmanage list vms | grep "\"${NAME_OF_BOX}\"" | wc -l`

if [ $count -ne 0 ]
then
	echo "Maszyna wirtualna serwera już istnieje"
else
	echo "Tworzę maszynę wirtualną serwera"
	vboxmanage import ../ubuntubox/box.ovf --vsys 0 --vmname "${NAME_OF_BOX}";
	vboxmanage modifyvm "${NAME_OF_BOX}" --nic1 bridged --bridgeadapter1 wlan0
	vboxmanage modifyvm "${NAME_OF_BOX}" --macaddress1 08002723A640
fi

## provision

vboxmanage startvm "${NAME_OF_BOX}" --type headless
echo "Czekamy 30 sekund by wszystko wystartowało"
sleep 30

ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`

ssh-copy-id vagrant@${ip}

ssh vagrant@$ip 'bash -s' < provision/bootstrap_server.sh

NEWUSER=deploy

ssh vagrant@$ip "sudo adduser --disabled-password --gecos '' $NEWUSER"
ssh vagrant@$ip "sudo adduser ${NEWUSER} ${NEWUSER}"
ssh vagrant@$ip "sudo bash -c 'echo \"${NEWUSER} ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/${NEWUSER}'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
cat ~/.ssh/id_rsa.pub | ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"


#ustawienia nginx+passenger
scp provision/nginx.conf ${NEWUSER}@${ip}:~
scp provision/default ${NEWUSER}@${ip}:~
#backup bazy
scp provision/backup_db.sh ${NEWUSER}@${ip}:~

ssh ${NEWUSER}@${ip} 'bash -s' < provision/bootstrap_deploy_user.sh

ssh ${NEWUSER}@${ip} "sudo sed -i -e 's/vagrant-ubuntu-trusty-64/${NAME_OF_BOX}/g' /etc/hostname"

ssh vagrant@$ip 'sudo reboot'

echo "Czekamy 30 sekund by wszystko wystartowało"
sleep 30

NEWUSER=staging

ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`

ssh vagrant@$ip "sudo adduser --disabled-password --gecos '' $NEWUSER"
ssh vagrant@$ip "sudo adduser ${NEWUSER} ${NEWUSER}"
ssh vagrant@$ip "sudo bash -c 'echo \"${NEWUSER} ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/${NEWUSER}'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
cat ~/.ssh/id_rsa.pub | ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"

scp provision/import_db.sh ${NEWUSER}@${ip}:~

ssh ${NEWUSER}@${ip} 'bash -s' < provision/bootstrap_staging_user.sh