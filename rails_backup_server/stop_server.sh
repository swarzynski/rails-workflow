#!/bin/bash
NAME_OF_BOX=rails_backup_server

ip=`VBoxManage guestproperty get "${NAME_OF_BOX}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }'`
ssh vagrant@$ip 'sudo poweroff'

