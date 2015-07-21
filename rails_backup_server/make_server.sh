#!/bin/bash

NAME_OF_BOX=rails_backup_server

if [ ! -f ../ubuntubox/box.ovf ]; then
    wget -P ../ubuntubox/ https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/20150609.0.10/providers/virtualbox.box
    tar xvf ../ubuntubox/virtualbox.box -C ../ubuntubox/
    rm ../ubuntubox/virtualbox.box
fi

count=`vboxmanage list vms | grep "${NAME_OF_BOX}" | wc -l`

if [ $count -ne 0 ]
then
	echo "Maszyna wirtualna serwera już istnieje"
else
	echo "Tworzę maszynę wirtualną serwera"
	vboxmanage import ../ubuntubox/box.ovf --vsys 0 --vmname "${NAME_OF_BOX}";
	vboxmanage modifyvm "${NAME_OF_BOX}" --nic1 bridged --bridgeadapter1 wlan0
	#vboxmanage modifyvm "${NAME_OF_BOX}" --macaddress1 
fi

## provision

vboxmanage startvm "${NAME_OF_BOX}" --type headless
echo "Czekamy 30 sekund by wszystko wystartowało"
sleep 30

ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`

ssh-copy-id vagrant@${ip}

NEWUSER=dupa11

ssh vagrant@$ip "sudo adduser --disabled-password --gecos '' $NEWUSER"
ssh vagrant@$ip "sudo adduser ${NEWUSER} ${NEWUSER}"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
cat ~/.ssh/id_rsa.pub | ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"
ssh vagrant@$ip "sudo bash -c 'echo \"${NEWUSER} ALL=NOPASSWD: ALL\" >> /etc/sudoers'"

#ssh vagrant@$ip 'bash -s' < provision/bootstrap_server.sh
ssh vagrant@$ip 'sudo reboot'