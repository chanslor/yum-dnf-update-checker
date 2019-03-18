#!/bin/bash

#Mon Dec 20 12:18:21 CDT 2017
#mdchansl@southernco.com

#Check for pending security patches
#Add dir stuff to rpm install
if [ ! -d /var/log/ems_yum_updates ] ; then
sudo mkdir -p /var/log/ems_yum_updates
sudo chmod 775 /var/log/ems_yum_updates
sudo chown root:unixadmin /var/log/ems_yum_updates
fi

DATE=$(date +%F)
SYSTEM=$(uname -n)
TODAY=$(date)
OUTAGE_TIME="NULL"

check_updates() {

if [[ "$(sudo yum updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -ge "1" ]] ; then
notify-send -u critical -t 999999999 "UPDATES" "You have pending UPDATES" --icon=dialog-information
echo "You have pending UPDATES" | write mdchansl pts/1
sudo echo "===============================================================================" > /var/log/ems_yum_updates/${DATE}.log 2>&1
sudo date >> /var/log/ems_yum_updates/${DATE}.log 2>&1
sudo yum updateinfo info >> /var/log/ems_yum_updates/${DATE}.log 2>&1
fi

}

notify_users() {
	USERS=$(/usr/bin/w | cut -d" " -f1 | sed -e '/^$/d' | /bin/grep -v USER | sort | uniq)
	for i in $USERS
	do
echo "You have pending OS UPDATES.

 --- $TODAY ---
This system, $SYSTEM is scheduled for reboot at $OUTAGE_TIME 
See /var/log/ems_yum_updates/ for details on patches being applied." | /bin/wall

	done
}

#Look at the Amazon code: update-motd.py

#if [ "$(sudo yum updateinfo 2>&1 | /bin/egrep "Bugfix|Enhancement|Security")" > "1" ] ; then

#Remove specific user stuff to config file
#/etc/sysconfig/check-update.conf
#USER=mdchansl

