NAME = piratebox-ws
VERSION = 1.1.4
ARCH = all
PB_FOLDER=piratebox
PB_SRC_FOLDER=$(PB_FOLDER)/$(PB_FOLDER)

PACKAGE_NAME=$(NAME)_$(VERSION)
PACKAGE=$(PACKAGE_NAME).tar.gz
VERSION_FILE=$(PB_FOLDER)/$(PB_FOLDER)/version
MOTD=$(PB_FOLDER)/$(PB_FOLDER)/rpi/motd.txt

IMAGE_FILE=piratebox_ws_1.1_img.gz
TGZ_IMAGE_FILE=piratebox_ws_1.1_img.tar.gz
SRC_IMAGE=image_stuff/OpenWRT_ext4_50MB.img.gz
SRC_IMAGE_UNPACKED=image_stuff/piratebox_img
MOUNT_POINT=image_stuff/image
OPENWRT_FOLDER=image_stuff/openwrt
OPENWRT_CONFIG_FOLDER=$(OPENWRT_FOLDER)/conf
OPENWRT_BIN_FOLDER=$(OPENWRT_FOLDER)/bin

WORKFOLDER=tmp

###IRC deployment
IRC_GITHUB_ULR=git://github.com/jrosdahl/miniircd.git
IRC_WORK_FOLDER=$(WORKFOLDER)/irc
IRC_SRC_SERVER=$(IRC_WORK_FOLDER)/miniircd
IRC_TARGET_SERVER=$(PB_SRC_FOLDER)/bin/miniircd.py

.DEFAULT_GOAL = package

$(IRC_TARGET_SERVER): 
	mkdir -p $(WORKFOLDER)
	git clone $(IRC_GITHUB_ULR) $(IRC_WORK_FOLDER)
	cp $(IRC_SRC_SERVER) $(IRC_TARGET_SERVER)

$(MOTD):
	sed -e 's|##version##|$(VERSION)|' rpi.motd-template.txt > $@

$(VERSION):
	echo "$(PACKAGE_NAME)" >  $(VERSION_FILE)
	echo `git status -sb --porcelain` >> $(VERSION_FILE)
	echo ` git log -1 --oneline` >>  $(VERSION_FILE)

$(PACKAGE): $(IRC_TARGET_SERVER) $(VERSION) $(MOTD)
	tar czf $@ $(PB_FOLDER)

$(IMAGE_FILE): $(IRC_TARGET_SERVER) $(VERSION) $(SRC_IMAGE_UNPACKED) $(OPENWRT_CONFIG_FOLDER) $(OPENWRT_BIN_FOLDER) $(MOTD)
	mkdir -p  $(MOUNT_POINT)
	echo "#### Mounting image-file"
	sudo  mount -o loop,rw,sync $(SRC_IMAGE_UNPACKED) $(MOUNT_POINT)
	echo "#### Copy content to image file"
	sudo   cp -vr $(PB_SRC_FOLDER)/*  $(MOUNT_POINT)     
	echo "#### Copy customizatiosns to image file"
	sudo   cp -rv $(OPENWRT_FOLDER)/* $(MOUNT_POINT)/ 
	echo "#### Umount Image file"
	sudo  umount  $(MOUNT_POINT)
	gzip -rc $(SRC_IMAGE_UNPACKED) > $(IMAGE_FILE)


$(OPENWRT_CONFIG_FOLDER):
	mkdir -p $@
	cp -rv $(PB_SRC_FOLDER)/conf/* $@
	sed 's:OPENWRT="no":OPENWRT="yes":'  -i $@/piratebox.conf 
	sed 's:DO_IFCONFIG="yes":DO_IFCONFIG="no":'  -i $@/piratebox.conf 
	sed 's:IPV6_ENABLE="no":IPV6_ENABLE="yes":'  -i $@/ipv6.conf 
	sed 's:USE_APN="yes":USE_APN="no":'  -i $@/piratebox.conf 
	sed 's:DNSMASQ_INTERFACE="wlan0":DNSMASQ_INTERFACE="br-lan":' -i $@/piratebox.conf 
	sed 's:192.168.77:192.168.1:g' -i $@/piratebox.conf 
	sed 's:DROOPY_USE_USER="yes":DROOPY_USE_USER="no":' -i  $@/piratebox.conf
	sed 's:DROOPY_CHMOD:#DROOPY_CHMOD:' -i $@/piratebox.conf
	sed 's:LEASE_FILE_LOCATION=$$PIRATEBOX_FOLDER/tmp/lease.file:LEASE_FILE_LOCATION=/tmp/lease.file:' -i  $@/piratebox.conf
	sed 's:TIMESAVE_FORMAT="+%C%g%m%d %H%M":TIMESAVE_FORMAT="+%C%g%m%d%H%M":' -i $@/piratebox.conf
	sed 's:FIREWALL_FETCH_DNS="yes":FIREWALL_FETCH_DNS="no":' -i $@/firewall.conf
	sed 's:FIREWALL_FETCH_HTTP="yes":FIREWALL_FETCH_HTTP="no":' -i $@/firewall.conf


$(OPENWRT_BIN_FOLDER):
	mkdir -p $@
	cp -v  $(PB_SRC_FOLDER)/bin/droopy $@
	sed "s:libc.so.6:libc.so.0:" -i $@/droopy

$(TGZ_IMAGE_FILE):
	tar czf  $(TGZ_IMAGE_FILE) $(SRC_IMAGE_UNPACKED) 


$(SRC_IMAGE_UNPACKED):
	gunzip -dc $(SRC_IMAGE) >  $(SRC_IMAGE_UNPACKED)


package:  $(PACKAGE)

all: package  shortimage

clean: cleanimage 
	rm -fr $(WORKFOLDER)
	rm -fr $(IRC_WORK_FOLDER)
	rm -f $(IRC_TARGET_SERVER)
	rm -f $(PACKAGE)
	rm -f $(VERSION_FILE) $(MOTD)

cleanimage:
	- rm -f  $(TGZ_IMAGE_FILE)
	- rm -f  $(SRC_IMAGE_UNPACKED)
	- rm -fr $(OPENWRT_CONFIG_FOLDER)
	- rm -v  $(IMAGE_FILE)
	- rm -rv $(OPENWRT_BIN_FOLDER)


shortimage: $(IMAGE_FILE) $(TGZ_IMAGE_FILE)



.PHONY: all clean package shortimage
