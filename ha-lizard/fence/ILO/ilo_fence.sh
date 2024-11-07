#!/bin/bash
##################################
# HA-Lizard version 2.3.2
##################################
#################################################################################################
#
# HA-Lizard - Open Source High Availability Framework for Xen Cloud Platform and XenServer
#
# Copyright 2021 Salvatore Costantino
# ha@pulsesupply.com
#
# This file is part of HA-Lizard.
#
#    HA-Lizard is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HA-Lizard is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with HA-Lizard.  If not, see <http://www.gnu.org/licenses/>.
#
##################################################################################################
exec 2>/dev/null
source /etc/ha-lizard/ha-lizard.init
source /etc/ha-lizard/ha-lizard.func

log "fence_host: Searching for IP address for host: $1"
HOST_IP=`(cat $FENCE_FILE_LOC/$FENCE_METHOD/$FENCE_METHOD.hosts | grep $1 | awk -F ":" '{print $2}')`
if [ $? = "0" ]
then
	log "fence_host: IP Address for host: $1 found: $HOST_IP"
	log "fence_host: Checking if fencing interface can be reached"
	ping -c 1 $HOST_IP
	if [ $? = "0" ]
	then
		log "fence_host: Host fence port on $HOST_IP response = OK"
		log "fence_host: Fence $HOST_IP -  TCL/SSH connection start"
		rm -f $FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.out
		`$FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.tcl $HOST_IP root $FENCE_PASSWD "$2 /system1 -f"`

                while read l
                do
                	log "fence_host: TCL Session Output: $l"
                done < $FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.out

                rm -f $FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.out
                log "fence_host: Checking power state of $1, ILO: $HOST_IP"
                `$FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.tcl $HOST_IP root $FENCE_PASSWD power`

                 while read l
                 do
                 	log "fence_host: TCL Session Output: $l"
                 done < $FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.out

                 POWER_STATE=`cat $FENCE_FILE_LOC/$FENCE_METHOD/ilo_fence.out | grep "power: server power is currently:" | awk -F ": " '{print $3}'`
                 log "fence_host: Server Power = $POWER_STATE"
                 if [[ "$POWER_STATE" == *Off* ]]
                 then
                 	ILO_SERVER_POWER=0
			exit 0
                 else
                 	ILO_SERVER_POWER=1
			exit 1
                 fi
	fi
else
	log "ILO check failed - aborting fencing"
fi
