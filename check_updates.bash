#!/bin/bash

#Mon Dec 20 12:18:21 CDT 2017
#mdchansl@southernco.com

#Check for pending security patches

if [ -f /tmp/check.txt ] ; then
sudo rm -f /tmp/check.txt
fi

#if [ "$(sudo yum updateinfo 2>&1 | /bin/egrep "Bugfix|Enhancement|Security")" > "1" ] ; then
if [[ "$(sudo yum updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -le "1" ]] ; then
notify-send -u critical -t 999999999 "UPDATES" "You have pending UPDATES" --icon=dialog-information
sudo yum updateinfo info > /tmp/check.txt 2>&1
fi
