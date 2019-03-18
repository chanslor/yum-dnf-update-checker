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
echo "Check for Security updates..."
return 0
else
echo "I don't know your runlevel"
exit 1
fi

}

check_updates() {

if [[ "$(yum updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -ge "1" ]] ; then
echo "===============================================================================" > /var/log/ems_yum_updates/${DATE}.log 2>&1
date >> /var/log/ems_yum_updates/${DATE}.log 2>&1
yum updateinfo info >> /var/log/ems_yum_updates/${DATE}.log 2>&1
return 100
fi

}

notify_users() {
echo "

        You have pending OS Security Updates.

 --- $TODAY ---
This system, $SYSTEM is scheduled for reboot at $OUTAGE_TIME 
See /var/log/ems_yum_updates/ for details on patches being applied."
#See /var/log/ems_yum_updates/ for details on patches being applied." | /bin/wall

}

runlevel_is || ( echo "Not at correct runlevel." && exit 1 )

check_updates || notify_users


