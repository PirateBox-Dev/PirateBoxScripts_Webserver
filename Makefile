NAME = piratebox-ws
VERSION = 0.7A
ARCH = all
PB_FOLDER=piratebox
PB_SRC_FOLDER=$(PB_FOLDER)/$(PB_FOLDER)

PACKAGE_NAME=$(NAME)_$(VERSION)
PACKAGE=$(PACKAGE_NAME).tar.gz
VERSION_FILE=$(PB_FOLDER)/$(PB_FOLDER)/version

IMAGE_FILE=piratebox_ws_0.7_img.gz
TGZ_IMAGE_FILE=piratebox_ws_0.7_img.tar.gz
SRC_IMAGE=image_stuff/OpenWRT.img.gz
SRC_IMAGE_UNPACKED=image_stuff/piratebox_img
MOUNT_POINT=image_stuff/image
OPENWRT_FOLDER=image_stuff/openwrt
OPENWRT_CONFIG_FOLDER=$(OPENWRT_FOLDER)/conf

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

$(VERSION):	
	echo "$(PACKAGE_NAME)" >  $(VERSION_FILE)

$(PACKAGE): $(IRC_TARGET_SERVER) $(VERSION)
	tar czf $@ $(PB_FOLDER) 


$(IMAGE_FILE): $(IRC_TARGET_SERVER) $(VERSION) $(SRC_IMAGE_UNPACKED) $(OPENWRT_CONFIG_FOLDER)
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
	sed 's:USE_APN="yes":USE_APN="no":'  -i $@/piratebox.conf 
	sed 's:DNSMASQ_INTERFACE="wlan0":DNSMASQ_INTERFACE="br-lan":' -i $@/piratebox.conf 
	sed 's:192.168.77:192.168.1:g' -i $@/piratebox.conf 
	sed 's:DROOPY_USE_USER="yes":DROOPY_USE_USER="no":' -i  $@/piratebox.conf

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
	rm -f $(VERSION_FILE)

cleanimage:
	- rm -f  $(TGZ_IMAGE_FILE)
	- rm -f  $(SRC_IMAGE_UNPACKED)
	- rm -fr $(OPENWRT_CONFIG_FOLDER)
	- rm -v  $(IMAGE_FILE)


shortimage: $(IMAGE_FILE) $(TGZ_IMAGE_FILE)



.PHONY: all clean package shortimage

