# PirateBoxScripts with Modifications for running in a Webserver     
&copy; 2013 [Matthias Strubel](mailto:matthias.strubel@aod-rpg.de) licenced under GPL-3

## Maintainers
* [Matthias Strubel](matthias.strubel@aod-rpg.de)     
* [Cale Black](cablack@rams.colostate.edu)

Sources for Running PirateBox with Webserver lighttpd     
Contains: Shoutbox, Forum

PirateBox is a collection of scripts / programs that allows you to use your wireless card
as a local network to share files and chat anonymously. For more information please visit
http://daviddarts.com/

## Info
Packages contains only scripts based PirateBox scripts with running lighttpd webserver.

PirateBox scripts can:
* Setup WLAN Interface via iw
* Setup hotspot functionality (hostapd)
* Setup IP Adresses of wlan interface
* Probing until USB-WLAN is available
* Can add wlan interface to an existing bridge
* Sets Up a DHCP Server with redirect to wlan-interface IP
* Upload landing page  (via iframe droopy)
* Browse Uploaded files
* Announce "Internet yes" for iOS
* Announce "Internet yes" for MS devices
* ShoutBox
* Optional small python Forum
* Optional imageboard
* Optional Station counter
* Optional Inihibit starting upload-script
* Optional Timesave script (for devices without RTC)  - can be found in piratebox/bin/timesave.sh 
* Optional Poll for WLAN device until it available (for USB wifi cards)

More information can be found on: http://piratebox.aod-rpg.de     
Installation-HowTo and current Download-Link: http://piratebox.aod-rpg.de/dokuwiki/doku.php/piratebox_lighttpd

Is supported by [mkPirateBox > v0.5 for OpenWRT Systems](https://github.com/MaStr/mkPirateBox)
and by [PirateBox Manager](https://github.com/TerrorByte/PirateBox-Manager).

## Installation
PirateBox should be in most common repositories soon, but in the mean time you can use this method:

### For alpha testing
Download the [development package](https://github.com/MaStr/PirateBoxScripts_Webserver/archive/development.zip).

Unzip the package:

    unzip development.zip

Run the installer in the unzipped folder:

    cd PirateBoxScripts_Webserver/piratebox
    sudo ./install.sh default
    #Default can be substituted with 'board' if you want an image board on your PirateBox
