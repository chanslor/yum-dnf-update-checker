#!/bin/bash

#Mon Dec 20 12:18:21 CDT 2017
#mdchansl@southernco.com

#Check for pending security patches
if [ ! -d /var/log/ems_yum_updates ] ; then
sudo mkdir -p /var/log/ems_yum_updates
sudo chmod 775 /var/log/ems_yum_updates
sudo chown root:unixadmin /var/log/ems_yum_updates
fi

DATE=$(date +%F)

#if [ "$(sudo yum updateinfo 2>&1 | /bin/egrep "Bugfix|Enhancement|Security")" > "1" ] ; then
if [[ "$(sudo yum updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -le "1" ]] ; then
#notify-send -u critical -t 999999999 "UPDATES" "You have pending UPDATES" --icon=dialog-information
sudo echo "===============================================================================" > /var/log/ems_yum_updates/${DATE}.log 2>&1
sudo date >> /var/log/ems_yum_updates/${DATE}.log 2>&1
sudo yum updateinfo info >> /var/log/ems_yum_updates/${DATE}.log 2>&1
fi
