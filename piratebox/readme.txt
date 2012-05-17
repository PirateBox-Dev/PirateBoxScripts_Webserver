## Piratebox for laptop (eeePc) script collection   WITH LIGHTTPD
##   created by Matthias Strubel (matthias.strubel@aod-rpg.de)  2011-03-19
##   licenced by gpl ;; please feel for improvements or feedback :)
##  Changes:
##    2011-03-19  First concept release with shoutbox left in python and droopy in perl
##    2011-08-04  Image-Board integration
##


####### OLD ###########


What to do? / Install
---------------------
  > Install debian
  > Install following Packages:
     - Perl  
     #  apt-get install perl
     - lighttpd
     #  apt-get install lighttpd
     - if needed : hostapn and/or dnsmasq
     # apt-get install hostapn
     # apt-get install dnsmasq

  > copy over the piratebox folder into /opt/ (as root)
    # sudo mkdir /opt 
    # sudo cp -rv piratebox /opt 
  > create a symlink /opt/piratebox/init.d/piratebox /etc/init.d/
     # sudo ln -s /opt/piratebox/init.d/piratebox /etc/init.d/piratebox  
  > add piratebox to you runlevel (optional)
    # sudo  update-rc.d piratebox defaults 
  > create a link from your share-device to /opt/piratebox/share
    # sudo ln -s /mnt/usbstick /opt/piratebox/share
  > define your personall options in
    # /opt/piratebox/conf/piratebox.conf        # Start which services, IPs etc
    # /opt/piratebox/conf/hostapd.conf          # Some stuff about beeing an APN 

  > Now please mount your usb-stick, share drive .. 
 
  > Run the follow script 
    # /opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf part2    

  > If you want to install kareha, please do the following steps:
    # /opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf imageboard
     >> This step installs a basic configuration for the board... 
     >> Edit /opt/piratebox/share/board/config.pl and change ADMIN_PASS and SECRET

I created
/opt/piratebox/bin    - Binarys and Scripts
/opt/piratebox/conf   - Piratebox related configs (seperated from the normal system-configs!)
/opt/piratebox/share  - Mountpoint (with the first start of piratebox, the correct permissions will be set)
/opt/piratebox/share/Shared   -  Unsorted upload folder
/opt/piratebox/share/board      -  imageboard location
/opt/piratebox/init.d - the init-script (later more?)
/opt/piratebox/www    - Webfolder with cgi-scripts and static html pages
/opt/piratebox/tmp    - Folder with the error-log




Change directory?
-------------------
If you decide not to run piratebox under /opt you have to change following scripts:
piratebox/conf/piratebox.conf
piratebox/init.d/piratebox
piratebox/conf/lighttpd/lighttpd.conf


Seperate Runlevel
-----------------
I'm using the piratebox on another runlevel, because I don't want to use it on daily work. So do not use the above update-rc.d command if you don't intend to start it always.
If you want to use it on another runlevel you can use
 #  update-rc.d piratebox enable 4
and disable other services, you don't need
 i.e.  # update-rc.d acpid disable 4
These examples are for debian based distributions.

