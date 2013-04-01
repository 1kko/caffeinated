#!/bin/bash

# General Daemonize control script - Ikko(me@1kko.com) / Apr. 1. 2013. 

# Disclaimer
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


## To enable debug mode, uncomment this
# set -x

# Process Path
PROCESS_PWD=/usr/bin

# Process Binary or Executable
PROCESS_BIN=caffeinate

# PID file is saved to following path. Should be able to read/write
PID_FILE=/private/var/tmp/$PROCESS_BIN.pid

# Process Option Arguments
PROCESS_OPTARG="-dust 0"

## caffeinate Option Description
# -d : create an assertion to prevent the display from sleeping
# -u : declares user is active.
# -s : prevents system from sleeping, only valid in AC power"
# -t : timeout value in seconds which this assertion has to be valid. 0 is forever.
# more option arguments can be found by typing 'man caffeinate'
## end of Option Description


function Show_Help()
{
	echo "$0 [options]"
	echo "	-e	Enable $PROCESS_BIN"
	echo "	-d	Disable $PROCESS_BIN"
	echo "	-s	Show Current Status"
	echo "	-r	Reload $PROCESS_BIN"
	echo "	-h	Show Help Message"
	echo "	without option, $PROCESS_BIN will toggle enable/disable"
	exit 1
}

function Get_PID()
{
	local PID
	[[ -f $PID_FILE ]] && PID="`cat $PID_FILE`"
	echo $PID
	[[ $PID ]] && return 1 || return 0
}

function Show_Process()
{
	local PID
	echo "Displaying Status."
	PID=`Get_PID`
	[[ $PID ]] && ps -ef $PID
}

function Check_Process()
{
	local PID PROCESS
	PID=`Get_PID`
	PROCESS="`ps -ef $PID`"
	[[ $PID ]] && return 0
	[[ $PROCESS ]] && return 1 || return 0
}

function Execute_Process()
{
	$PROCESS_PWD/$PROCESS_BIN $PROCESS_OPTARG &
	echo $! > $PID_FILE
	echo "$PROCESS_BIN enabled. Stops idle sleep."
}

function Halt_Process()
{
	local PID
	PID=`Get_PID`
	[[ $PID ]] && kill -9 $PID && echo "$PROCESS_BIN disabled. Back to normal mode."
	[[ -f $PID_FILE ]] && rm -f $PID_FILE
}

function Toggle_Process()
{
	[[ Check_Process ]] && Halt_Process || Execute_Process
}

[[ -z $1 ]] && Toggle_Process

while getopts "edsr" OPTNAME
do
	case "$OPTNAME" in
		e)
			if Check_Process; then
				echo "$PROCESS_BIN is running already"
				Show_Process
				exit 1
			fi
			Execute_Process
			Show_Process
			;;
		d)
			if ! Check_Process; then
				echo "$PROCESS_BIN is not running"
				exit 1
			fi
			Halt_Process
			Show_Process
			;;
		s)
			if ! Check_Process; then
				echo "$PROCESS_BIN is not running"
				exit 1
			fi
			Show_Process
			;;
		r)
			Halt_Process && sleep 1
			Execute_Process
			Show_Process
			;;
		*)
			Show_Help
			;;
	esac
done
shift $(($OPTIND -1 ))

