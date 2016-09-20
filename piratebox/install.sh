#!/bin/bash
#=======================================================================
#
#          FILE:  install.sh
# 
#         USAGE:  ./install.sh 
# 
#   DESCRIPTION:  Install file for PirateBox. 
# 
#       OPTIONS:  ./install.sh <default|board> <optional: USB path>
#  REQUIREMENTS:  ---
#          BUGS:  Link from install
#         NOTES:  ---
#        AUTHOR: Cale 'TerrorByte' Black, cablack@rams.colostate.edu
#       COMPANY:  ---
#       CREATED: 02.02.2013 19:50:34 MST
#      REVISION:  0.3.1
#       LICENCE: (c) Cale Black, 2013 GPL-3
#=======================================================================
#Import PirateBox conf
CURRENT_CONF=piratebox/conf/piratebox.conf
scriptfile="$(readlink -f $0)"
CURRENT_DIR="$(dirname ${scriptfile})"

#Must be root
if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" #1>&2
        exit 0
fi

if [[ $1 ]]; then
	echo "Installing..."
else
	echo "Useage: /bin/bash install.sh <default|board>"
	exit 0
fi

if [[ -f  "$CURRENT_DIR"/$CURRENT_CONF ]]; then
	. $CURRENT_CONF 2> /dev/null
else
	echo "PirateBox config is not in its normal directory"
	exit 0
fi

#begin setting up piratebox's home dir
if [[ ! -d /opt ]]; then
	mkdir -p /opt
fi

cp -rv "$CURRENT_DIR"/piratebox /opt &> /dev/null
echo "Finished copying files..."
echo "$NET.$IP_SHORT piratebox.lan">>/etc/hosts
echo "$NET.$IP_SHORT piratebox">>/etc/hosts

if [[ -d /etc/init.d/ ]]; then
	ln -s /opt/piratebox/init.d/piratebox /etc/init.d/piratebox
	echo "To make PirateBox start at boot run: update-rc.d piratebox defaults"
#	systemctl enable piratebox #This enables PirateBox at start up... could be useful for Live
else
	#link between opt and etc/pb
	ln -s /opt/piratebox/init.d/piratebox.service /etc/systemd/system/piratebox.service
	echo "To make PirateBox start at boot run: systemctl enable piratebox"
fi

#install dependencies
#TODO missing anything in $DEPENDENCIES?
# Modified Script by martedì at http://www.mirkopagliai.it/bash-scripting-check-for-and-install-missing-dependencies/
PKGSTOINSTALL="hostapd lighttpd dnsmasq"

# If some dependencies are missing, asks if user wants to install
if [ "$PKGSTOINSTALL" != "" ]; then
	echo -n "Some dependencies may missing. Would you like to install them? (Y/n): "
	read SURE
	# If user want to install missing dependencies
	if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
		# Debian, Ubuntu and derivatives (with apt-get)
		if which apt-get &> /dev/null; then
			apt-get install $PKGSTOINSTALL
		# OpenSuse (with zypper)
		#elif which zypper &> /dev/null; then
		#	zypper in $PKGSTOINSTALL
		# Mandriva (with urpmi)
		elif which urpmi &> /dev/null; then
			urpmi $PKGSTOINSTALL
		# Fedora and CentOS (with yum)
		elif which yum &> /dev/null; then
			yum install $PKGSTOINSTALL
		# ArchLinux (with pacman)
		elif which pacman &> /dev/null; then
			pacman -Sy $PKGSTOINSTALL
		# Else, if no package manager has been found
		else
			# Set $NOPKGMANAGER
			NOPKGMANAGER=TRUE
			echo "ERROR: No package manager found. Please, manually install: $PKGSTOINSTALL."
		fi
	fi
fi

#install piratebox with the given option
case "$1" in
	default)
		/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf part2
		;;
	board)
		/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf imageboard
		echo "############################################################################"
		echo "#Edit /opt/piratebox/share/board/config.pl and change ADMIN_PASS and SECRET#"
		echo "############################################################################"
		;;
	*)
		echo "$1 is not an option. Useage: /bin/bash install.sh <default|board>"
		exit 0
		;;
esac

echo "##############################"
echo "#PirateBox has been installed#"
echo "##############################"
echo ""
echo "Use: sudo service piratebox <start|stop>"
echo "or for systemd systems Use: sudo systemctl <start|stop|restart> piratebox"
exit 0
