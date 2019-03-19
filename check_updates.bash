#!/bin/bash

# Mon Dec 20 12:18:21 CDT 2017
# michael.chanslor@gmail.com
#
# author: Mike Chanslor
#
# desc: Fedora, Oracle Linux and RHEL Security Update Check script.
#
# Copyright (C) 2017 Michael D. Chanslor
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################

# This script is placed in /etc/cron.hourly/
#
# Schedules system for patching on $DAY_TO_PATCH 
# and reboots on $DAY_TO_REBOOT and $HOUR_TO_REBOOT
#
#This script only checks for pending *Security* patches
#


#To Do: Place these vars into /etc/sysconfig/check_updates.conf for user modification.
#User vars
#DAY_TO_PATCH="Monday"
DAY_TO_PATCH="Tuesday"
DAY_TO_REBOOT="Tuesday"
HOUR_TO_REBOOT="NOW"
LOG_DIR="/var/log/check_updates"

#System vars
DATE=$(date +%F)
SYSTEM=$(uname -n)
TODAY=$(date)
OUTAGE_TIME="NULL"
DAY=$(/bin/date +%A)


if [ ! -d /var/log/check_updates ] ; then
	sudo mkdir -p /var/log/check_updates
	sudo chmod 775 /var/log/check_updates
else
	#Clean logs older than 4 days
	if [ -d $LOG_DIR ] ; then
	cd $LOG_DIR && find . -type f -name \*.log -mtime +3 | xargs rm -f
	fi
fi


release_ver() {
	RELEASE=$(lsb_release -i | awk ' { print $3 } ')
	case $RELEASE in
		Fedora)
			echo "Your Distro is Fedora"
			export YUM=dnf
			;;
		OracleServer)
			echo "Your Distro is Oracle Linux"
			export YUM=yum
			;;
		RedHatenterpriseServer)
			echo "Your Distro is RHEL"
			export YUM=yum
			;;
		*)
			return 200
			;;
	esac

}

runlevel_is() {

RUNLEVEL=$(runlevel | cut -d" " -f2)

# What Would SystemD do?
if [[ "$RUNLEVEL" -eq "3" || "$RUNLEVEL" -eq "5" ]]; then
echo "Sanity check: You are at runlevel 3 or 5"
echo "Check for Security updates..."
return 0
else
echo "I don't know your runlevel"
exit 1
fi

}

check_updates() {

$YUM clean all > /dev/null 2>&1

if [[ "$($YUM updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -ge "1" ]] ; then
echo "===============================================================================" > /var/log/check_updates/${DATE}.log 2>&1
date >> ${LOG_DIR}/${DATE}.log 2>&1
$YUM updateinfo info >> ${LOG_DIR}/${DATE}.log 2>&1

return 100
fi

}

no_updates() {
	echo
	echo "No Security updates."
	echo
}

notify_users() {
echo "

        You have pending OS Security Updates.

 --- $TODAY ---
This system, $SYSTEM is scheduled for reboot at $OUTAGE_TIME 
See /var/log/check_updates/ for details on patches being applied."
#See /var/log/check_updates/ for details on patches being applied." | /bin/wall

}

day_to_patch() {
	if [[ ${DAY} == ${DAY_TO_PATCH} ]]; then
	echo "We download and install patches today."
	else
	echo "Not patching today."
	return 2
	fi
}

patch_it() {
	#$YUM update-minimal --security >> ${LOG_DIR}/${DATE}-yum-update-evidence.log 2>&1
	echo "YUM update-minimal --security"
	touch /root/check_updates
	exitCode=$?
	if [ $exitCode -ne "0" ] ; then
	echo "yum update failed."
	echo "See erros in ${LOG_DIR}/${DATE}-yum-update-evidence.log"
	exit 1
	fi
	
}


#MAIN

#day_to_reboot
#/root/check_updates
#hour_to_reboot

release_ver || (echo "Not a supported Linux distro." && exit 1)

runlevel_is || ( echo "Not at correct runlevel." && exit 1 )

(check_updates | pv -t && no_updates ) || notify_users

(day_to_patch && patch_it) || echo "$DAY is not your day to patch"

