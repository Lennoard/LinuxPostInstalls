#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NOCOLOR='\033[0m'

error() {
	printf "${RED}$1${NOCOLOR}\n"
}

warn() {
	printf "${ORANGE}$1${NOCOLOR}\n"
}


if [[ $EUID -ne 0 ]]; 
then
	d=`command -v dialog`
	if [ -z "$d" ]
	then
		error "Please install 'dialog' first -> sudo apt install dialog"
		exit 1
	fi

	tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
	$d \
		--backtitle "Linux Post Intall Script" \
		--title "DISTRO SELECT" --clear \
    	--radiolist "This script should install all software selected by you.\n\
		It may ocasionally require input from you too.\n\n\
		Please select your distro from the list bellow using the space bar key.\n\n\
		Press ENTER when you're done." 20 61 5 \
        "linuxmint20.1"  "Linux Mint 20.1 'Ulyssa'" ON \
		"linuxmint20"  "Linux Mint 20 'Ulyana'" off 2> $tempfile

	retval=$?

	choice=`cat $tempfile`
	case $retval in
	0)
		warn "Executing $choice script..."]
		sleep 1.5
		wget "https://raw.githubusercontent.com/Lennoard/LinuxPostInstalls/master/$choice.sh"
		sudo bash "$choice.sh" $USER $HOME
		;;
	1)
		warn "Canceled"
		exit 1
		;;
	255)
		error "Canceled"
		exit 1
		;;
	esac
else
	error "You should NOT run me directly as root. Close the terminal window and try again." 
   	exit 1
fi
