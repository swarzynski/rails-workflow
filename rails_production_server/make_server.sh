#!/bin/bash

NAME_OF_BOX=rails_production_server

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
	vboxmanage modifyvm "${NAME_OF_BOX}" --macaddress1 08002723A640
fi

## provision

vboxmanage startvm "${NAME_OF_BOX}" --type headless
echo "Czekamy 30 sekund by wszystko wystartowało"
sleep 30

ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`

ssh-copy-id vagrant@${ip}

#tylko dla production
scp provision/nginx.conf vagrant@${ip}:~
scp provision/default vagrant@${ip}:~

ssh vagrant@$ip 'bash -s' < provision/bootstrap_server.sh
ssh vagrant@$ip 'sudo reboot'