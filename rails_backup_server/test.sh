#!/bin/bash
NAME_OF_BOX=rails_backup_server
ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`

NEWUSER=dupa11

ssh vagrant@$ip "sudo adduser --disabled-password --gecos '' $NEWUSER"
ssh vagrant@$ip "sudo adduser ${NEWUSER} ${NEWUSER}"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa'"
ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
cat ~/.ssh/id_rsa.pub | ssh vagrant@$ip "sudo -H -u $NEWUSER bash -c 'cat >> ~/.ssh/authorized_keys'"
ssh vagrant@$ip "sudo bash -c 'echo \"${NEWUSER} ALL=NOPASSWD: ALL\" >> /etc/sudoers'"

#sudo -S -u dupa3 -i /bin/bash -l -c 'echo "dupa" >> ~/dupa.txt'
#sudo -i -u dupa3 echo \$HOME
#sudo -H -u otheruser bash -c 'echo "I am $USER, with uid $UID"' 


#ssh vagrant@$ip 'sudo -H -u dupa3 bash -c "touch ~/.ssh/authorized_keys"'
#cat ~/.ssh/id_rsa.pub | ssh vagrant@$ip 'sudo -H -u dupa3 bash -c "cat >> ~/.ssh/authorized_keys"'