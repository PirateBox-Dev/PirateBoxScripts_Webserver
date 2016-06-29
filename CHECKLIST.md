# Image Testing Checklist
If you are part of the testing team, this Checklist is for you.

## For RaspberryPi
Download the image, dump it to SD card, connect your PirateBox to the same network the computer you are testing from is connected to and then go through the checklist step by step to make sure everything is working as it should.
Before going through the checklist, make sure your USB WiFi is attached and is one of the supported types. Also make sure you have a *FAT32* formatted USB thumb drive attached to your RPi.

## For OpenWrt
Download the corresponding install_piratebox.zip and .bin file for your device. If you have already a PirateBox running, follow the upgrade instructions. If you install your Software on a fresh device, follow the installation howto
Make sure you PirateBox stopped flashing (indicating the installation is running). On PirateBox 1.1.0 the installation happens in multiple interations.


## Checklist
(Skip sections which are not valid for your architecture).

### Initial configuration setup
* [ ] PirateBox' WiFi is available
* [ ] Connection to PirateBox' WiFi could be established
* [ ] **RPi only**  SSH connection to PirateBox with the username *alarm* and the password *alarm* could be established
* [ ] **RPi only**  Message of the day containing information about *First Steps* is displayed correctly
* [ ] **RPi only** Change the password for the *alarm* user, log out and log back in
* [ ] **RPi only** Enable USB share
* [ ] Set some date and enable Fake-timeservice
* [ ] Enable Kareha Image and Discussion Board
* [ ] Enable UPnP media server (minidlna)
* [ ] It is possible to post to the chat
* [ ] It is possible to upload files
* [ ] It is possible to post to the board
* [ ] Reboot
* [ ] PirateBox' WiFi is available
* [ ] Connection to PirateBox' WiFi could be established
* [ ] Date matches the set date from the Fake-timeservice

### Functional tests
**UI in General**
* [ ] UI looks proper, no ugly overlapping
* [ ] UI is responsive on small browser size; is adjusts the look
* [ ] Every URL is working, on main screen
* [ ] Title URLs to mainscreen and Forum are working in Directory-Listing

**ImageBoard**
* [ ] It is possible to post new threads
* [ ] These threads can be answered on
* [ ] When I come back later to the imageboard and post a reply, the post order is correct.
* [ ] I can upload files (<5MB) to the posts as well

**Shoutbox**
* [ ] Different color work in Shoutbox , Username can be changed
* [ ] Posting URLs or other HTML like special characters do not break Shoutbox

**Upload**
* [ ] Upload of different filetypes works
* [ ] Multiple files can be uploaded
* [ ] The messages inside the upload box are in english or my language
* [ ] Special characters are correctly uploaded
* [ ] It is not possible to upload a file named index.html

**Directory Listing**
* [ ] Download of files is possible
* [ ] Directory listing reacts responsive on screen size changes
* [ ] Created folders are accessiable (UI is deployed after reboot)
* [ ] URLs to mainpage and forum in subfolder work
* [ ] Special character files uploaded via upload functionality work

**UPNP Server**
* [ ] Streaming of MP3 works via an UPNP client
* [ ] It is possible to stream videos via UPNP

**IRC Server**
* [ ] Is started after activation in piratebox.conf
* [ ] With an IRC client, the IRC server is usable
* [ ] New channels can be created

**Customization**
* [ ] Changes on the folder "content" on the USB Stick (**valid for OpenWrt** and RPI **with USB Storage mod**) are visible on the browser
* [ ] PHP was sucessfully enabled in lighttpd.conf and fastcgi processes are visible in "ps"
* [ ] My custom PHP script is working in /content folder
* [ ] Deleting the content folder creates a new folder after a reboot
* [ ] It is possible to change the visible hostname of piratebox using the install_piratebox.sh script

**Enhanced Network Configuration**
* [ ] Clients with static DNS Server entries work while being connected to PirateBox (PirateBox interferes here)
* [ ] One Client can not ping or connect to another Client (directly via wifi)
* [ ] 
