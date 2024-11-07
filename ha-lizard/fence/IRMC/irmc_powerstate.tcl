#!/usr/bin/expect
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

log_user 0
log_file -a /etc/ha-lizard/fence/IRMC/irmc_fence.out

set IP		[lindex $argv 0]
set USERNAME	[lindex $argv 1]
set PASSWORD	[lindex $argv 2]

spawn ssh -o "StrictHostKeyChecking no" $USERNAME@$IP


set timeout 10
expect  { 
    timeout 	{ puts "failed to get password prompts" ; exit 1 }
    eof		{ puts "SSH failure"			; exit 1 }
    "*assword:" { send "$PASSWORD\r" }
}

set timeout 5
expect  { 
    timeout 	{ puts "failed to get main menu"        ; exit 1 }
    eof		{ puts "SSH failure"			; exit 1 }
    "Permission denied"  { puts "wrong password"	; exit 1 }
    "Power Status : On"  { puts "On"  }
    "Power Status : Off" { puts "Off" }
}

exit 0
