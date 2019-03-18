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

runlevel_is() {
RUNLEVEL=$(runlevel | cut -d" " -f2)

if [[ "$RUNLEVEL" -eq "3" || "$RUNLEVEL" -eq "5" ]]; then
echo "You are at runlevel 3 or 5"
return 0
else
echo "I don't know your runlevel"
exit 1
fi

}

check_updates() {

#Remove specific user stuff to config file
#/etc/sysconfig/check-update.conf
#USER=mdchansl

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

runlevel_is || echo "Not at correct runlevel."



