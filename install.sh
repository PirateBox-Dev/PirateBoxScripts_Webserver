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
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Cale 'TerrorByte' Black, cablack@rams.colostate.edu
#       COMPANY:  ---
#       CREATED: 02.02.2013 14:10:24 MST
#      REVISION:  ---
#=======================================================================
CURRENT_CONF=piratebox/piratebox/conf/piratebox.conf
#import piratebox conf to install
if [[ -f $1 ]]; then
	echo "Installing..."
else
	echo "Useage: /bin/bash install.sh <default|board> <OPTIONAL: USB full path>"
	exit 0
fi

if [[ -f  $CURRENT_CONF ]]; then
	. $CURRENT_CONF 2> /dev/null
else
	echo "PirateBox config is not in its normal directory"
	exit 0
fi

#must be run as root, due to installing in /opt/
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" #1>&2
	exit 0
fi

#Permissions
#TODO?

#begin setting up piratebox's home dir
if [[ -d /opt ]]; then
	cp -rv piratebox /opt
else
	mkdir /opt
	cp -rv piratebox /opt
fi

if [[ -d /etc/systemd/system/ ]]; then
	ln -s /opt/piratebox/init.d/piratebox.service /etc/systemd/system/piratebox.service
	systemctl enable piratebox
else
	#link between opt and etc/pb
	ln -s /opt/piratebox/init.d/piratebox /etc/init.d/piratebox
	update-rc.d piratebox defaults
fi

#install dependencies
# Check what dependencies are missing?
#TODO missing anything in $DEPENDENCIES?
# Modified Script by martedì at http://www.mirkopagliai.it/bash-scripting-check-for-and-install-missing-dependencies/
DEPENDENCIES=(hostapd lighttpd dnsmasq)
PKGSTOINSTALL=""
if [[ ! `dpkg -l | grep -w "ii  ${DEPENDENCIES[$i]} "` ]]; then
	PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
fi
# OpenSuse, Mandriva, Fedora, CentOs, ecc. (with rpm)
if which rpm &> /dev/null; then
	if [[ ! `rpm -q ${DEPENDENCIES[$i]}` ]]; then
	PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
fi

# ArchLinux (with pacman)
elif which pacman &> /dev/null; then
	if [[ ! `pacman -Qqe | grep "${DEPENDENCIES[$i]}"` ]]; then
	PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
fi
# If it's impossible to determine if there are missing dependencies, mark all as missing
else
	PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}

# If some dependencies are missing, asks if user wants to install
if [ "$PKGSTOINSTALL" != "" ]; then
	echo -n "Some dependencies are missing. Want to install them? (Y/n): "
	read SURE
	# If user want to install missing dependencies
	if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
		# Debian, Ubuntu and derivatives (with apt-get)
		if which apt-get &> /dev/null; then
			apt-get install $PKGSTOINSTALL
		# OpenSuse (with zypper)
		elif which zypper &> /dev/null; then
			zypper in $PKGSTOINSTALL
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
			echo "ERROR: No package manager found. Please, manually install: ${DEPENDENCIES[*]}."
		fi
		# Check if installation is successful
		if [[ $? -eq 0 && ! -z $NOPKGMANAGER ]] ; then
			echo "All dependencies are installed."
		# Else, if installation isn't successful
		else
			echo "ERROR: Some dependencies were not installed or failed. Please, manually install ${DEPENDENCIES[*]}."
		fi
	# Else, if user don't want to install missing dependencies
	else
		echo "WARNING: Some dependencies may be missing. Manually install ${DEPENDENCIES[*]}."
	fi
fi

#install piratebox with the given option
case "$1" in
	default)
		/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf part2
		;;
	board)
		/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf imageboard
		echo "Edit /opt/piratebox/share/board/config.pl and change ADMIN_PASS and SECRET"
		;;
	*)
		echo "$1 is not an option. Useage: /bin/bash install.sh <default|board> <OPTIONAL: USB full path>"
		exit 0
		;;
esac

if [[ -f $2 ]]; then
	ln -s $1 /opt/piratebox/share
	echo "Files placed on $1 will be shared"
	echo "In order to change this remove the symlink between $1 and /opt/piratebox/share"
else
	echo "USB not found, not creating a link between the PirateBox share folder and the USB drive"
	echo "If you want to create a link between a USB drive and the share folder then run 'piratebox link <USB Drive full path>'"
fi

echo "##############################"
echo "#PirateBox has been installed#"
echo "##############################"
echo ""
echo "Use: service piratebox <start|stop|restart|link>"
echo "or for systemd systems Use: systemctl <start|stop|restart|link> piratebox"
