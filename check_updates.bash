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
# Executes on $DAY_TO_RUN
# Schedules system for patch on $DAY_PATCH 
# and reboots on $DAY_TO_REBOOT and $HOUR_TO_REBOOT
#
#This script only checks for pending *Security* patches
#

#Make directories.
if [ ! -d /var/log/check_updates ] ; then
sudo mkdir -p /var/log/check_updates
sudo chmod 775 /var/log/check_updates
fi

#setup vars
DAY_TO_PATCH="Tuesday"
DAY_TO_REBOOT="Tuesday"
HOUR_TO_REBOOT="NOW"
DATE=$(date +%F)
SYSTEM=$(uname -n)
TODAY=$(date)
OUTAGE_TIME="NULL"
LOG_DIR="/var/log/check_updates"
DAY=$(/bin/date +%A)

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

# Sanity check
# What Would SystemD do?
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

#Clean logs older than 4 days
if [ -d $LOG_DIR ] ; then
cd $LOG_DIR && find . -type f -name \*.log -mtime +3 | xargs rm -f
fi

if [[ "$($YUM updateinfo 2>&1 | /bin/grep "Security" | wc -l)" -ge "1" ]] ; then
echo "===============================================================================" > /var/log/check_updates/${DATE}.log 2>&1
date >> /var/log/check_updates/${DATE}.log 2>&1
$YUM updateinfo info >> /var/log/check_updates/${DATE}.log 2>&1

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
	exit 0
	fi
}

#MAIN

day_to_patch

exit 0

day_to_reboot
hour_to_reboot

release_ver || (echo "Not a supported Linux distro." && exit 1)

runlevel_is || ( echo "Not at correct runlevel." && exit 1 )

(check_updates && no_updates ) || notify_users


