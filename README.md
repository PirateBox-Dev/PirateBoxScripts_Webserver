# PirateBoxScripts with Modifications for running in a Webserver     

[![Join the chat at https://gitter.im/PirateBox-Dev/PirateBoxScripts_Webserver](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/PirateBox-Dev/PirateBoxScripts_Webserver?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  

© 2012-2019 [Matthias Strubel](mailto:matthias.strubel@aod-rpg.de) 

Licensed under the GNU GPLv3

## Maintainers
* [Matthias Strubel](matthias.strubel@aod-rpg.de)


PirateBox is a collection of scripts / programs that allows you to use your wireless card
as a local network to share files and chat anonymously. For more information please visit
[piratebox.cc](https://piratebox.cc)

## Info
Packages contains only scripts based PirateBox scripts with running lighttpd webserver.

PirateBox scripts can:
   * Setup WLAN Interface via iw
   * Setup hotspot functionality (hostapd)
   * Setup IP Adresses of wlan interface
   * Proping until USB-WLAN is available
   * Can add wlan interface to an existing bridge
   * Sets Up a DHCP Server with redirect to wlan-interface IP
   * Upload landing page  (via iframe droopy)
   * Browse Uploaded files
   * Announce "Internet yes" for iOS
   * Announce "Internet yes" for MS devices
   * ShoutBox
   * Optional small Python forum
   * Optional imageboard
   * Optional Station counter
   * Optional Inihibit starting upload-script
   * Optional Timesave script (for devices without RTC)  - can be found in piratebox/bin/timesave.sh 
   * Optional Poll for WLAN device until it available (for USB wifi cards)
   * Optional IRC-Server

More information can be found on [piratebox.cc](https://piratebox.cc)
Installation tutorial and current download link: [piratebox.cc/getting_started](https://piratebox.cc/getting_started)<!--I'm pretty sure I did the right link but if not you can uncomment this link http://piratebox.aod-rpg.de/dokuwiki/doku.php/piratebox_lighttpd-->

Is supported by [mkPirateBox](https://github.com/MaStr/mkPirateBox) > v0.5 for OpenWRT Systems 
and by [PirateBox Manager](https://github.com/TerrorByte/PirateBox-Manager)

## Installation
PirateBox should be in most common repositories soon, but in the meantime you can go to [piratebox.cc/getting_started](https://piratebox.cc/getting_started)

## Note
PirateBox is going to be discontinued. Read [this forum post](https://forum.piratebox.cc/read.php?9,23070) for more information.


<!--### Installing unstable (development version)

Download the package [here](https://github.com/MaStr/PirateBoxScripts_Webserver/archive/development.zip)

Unzip the package:
`$ unzip development.zip`

Run the installer in the unzipped folder:
`$ cd PirateBoxScripts_Webserver/piratebox && sudo ./install.sh default #Default can be substituted with 'board' if you want an image board on your PB`
-->
