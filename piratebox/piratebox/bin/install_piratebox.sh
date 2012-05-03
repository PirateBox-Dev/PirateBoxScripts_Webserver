#!/bin/sh
## PirateBox installer script  v.01
##  created by Matthias Strubel   2011-08-04
##

## ASH does not support arrays, so no nice foreach 
# All Perl packages for kareha
##OPENWRT_PACKAGES_IMAGEBOARD=(  perl perlbase-base perlbase-cgi perlbase-essential perlbase-file perlbase-bytes perlbase-config perlbase-data perlbase-db-file perlbase-digest perlbase-encode perlbase-encoding perlbase-fcntl perlbase-gdbm-file perlbase-integer perlbase-socket perlbase-unicode perlbase-utf8 perlbase-xsloader  )



# Load configfile

if [ -z  $1 ] || [ -z $2 ]; then 
  echo "Usage install_piratebox my_config <part>"
  echo "   Parts: "
  echo "       init_openwrt   : Stuff needed on openwrt-systems"
  echo "       part2          : sets Permissions and links correctly"
  echo "       imageboard     : configures kareha imageboard with Basic configuration"
  echo "                        should be installed in <Piratebox-Folder>/share/board"
  echo "       pyForum        : Simple PythonForum"
  exit 1
fi


if [ !  -f $1 ] ; then 
  echo "Config-File $1 not found..." 
  exit 1 
fi

#Load config
. $1 

if [ $2 = 'init_openwrt' ] ; then
  echo "-------------- Initialize PirateBoxScripts -----------"
    #Load openwrt-common config and procedures file!
    . /etc/piratebox.common
    #  cp -v $pb_pbmount/src/* "$pb_share"
    #  cp -v $pb_pbmount/src/.* $pb_share

# not needed anymore    cp_src  $pb_pbmount/src $pb_share

    touch "$pb_pbmount/conf/init_done"

    # Copy Removed, File is included in lib folder.. 
    #cp /usr/share/piratebox/CGIHTTPServer.py $pb_pbmount/chat
    rm -r $pb_pbmount/share
    ln -sf $pb_share $pb_pbmount/share
    chmod a+rw $CHATFILE
 fi

if [ $2 = 'pyForum' ] ; then
    cp -v $PIRATEBOX_FOLDER/src/forest.py  $WWW_FOLDER/cgi-bin
    cp -v $PIRATEBOX_FOLDER/src/forest.css $WWW_FOLDER/
    cp -v $PIRATEBOX_FOLDER/src/forum_forest.html  $WWW_FOLDER/forum.html
    mkdir -p $PIRATEBOX_FOLDER/forumspace
    chmod a+rw -R  $PIRATEBOX_FOLDER/forumspace
    chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_FOLDER/cgi-bin/forest.py
    chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_FOLDER/forest.css
    chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_FOLDER/forum.html
    echo "Copied the files. Recheck your PirateBox now. "
fi



if [ $2 = 'part2' ] ; then
#Create directories 
   mkdir -p $PIRATEBOX_FOLDER/share/unsorted
   mkdir -p $PIRATEBOX_FOLDER/share/board
   mkdir -p $PIRATEBOX_FOLDER/share/tmp
   mkdir -p $PIRATEBOX_FOLDER/tmp

#Set permissions
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/share -R
   chmod  u+rw $PIRATEBOX_FOLDER/share
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/www -R
   chmod u+x $PIRATEBOX_FOLDER/www/cgi-bin/* 
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/tmp
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/tmp -R

#Copy over the index.html for redirect to Droopy-Landing page
   cp $PIRATEBOX_FOLDER/www/index.html $PIRATEBOX_FOLDER/share

#Install a small script, that the link on the main page still works
   if  [ !  -f $PIRATEBOX_FOLDER/share/board/kareha.pl ] ; then  
      cp $PIRATEBOX_FOLDER/src/kareha.pl $PIRATEBOX_FOLDER/share/board
   fi
   
   ln -s $PIRATEBOX_FOLDER/share/board $PIRATEBOX_FOLDER/www/board
   ln -s $PIRATEBOX_FOLDER/share/unsorted $PIRATEBOX_FOLDER/www/unsorted
fi 

#Install the image-board
if [ $2 = 'imageboard' ] ; then
   
    if [ "$OPENWRT" = "yes" ] ; then
      if ! opkg update 
        then
          echo "ERROR: Not Internet Conenction"
          exit 5
      fi

#    for package in ${OPENWRT_PACKAGES[@]}
#       do
#         echo "Start install package $package ...."
#         opkg -d piratebox install $package
#         if [ $? ne 0 ] ; then
#               echo "ERROR installing $package"
#               exit 5
#         fi
#      done
###------------------------------------------
#  ASH does not support arrays :(
###-----------------------------------------
	opkg -d piratebox install perl
	opkg -d piratebox install perlbase-base 
	opkg -d piratebox install perlbase-cgi
	opkg -d piratebox install perlbase-essential
	opkg -d piratebox install perlbase-file
	opkg -d piratebox install perlbase-bytes
	opkg -d piratebox install perlbase-config 
	opkg -d piratebox install perlbase-data
	opkg -d piratebox install perlbase-db-file 
	opkg -d piratebox install perlbase-digest
	opkg -d piratebox install perlbase-encode
	opkg -d piratebox install perlbase-encoding
	opkg -d piratebox install perlbase-fcntl
	opkg -d piratebox install perlbase-gdbm-file
	opkg -d piratebox install perlbase-integer
	opkg -d piratebox install perlbase-socket
	opkg -d piratebox install perlbase-time
	opkg -d piratebox install perlbase-unicode
	opkg -d piratebox install perlbase-unicore
	opkg -d piratebox install perlbase-utf8
	opkg -d piratebox install perlbase-xsloader
	opkg -d piratebox install unzip

	ln -s /usr/local/bin/perl /usr/bin/perl
	ln -s /usr/local/lib/perl* /usr/lib/
    fi

    echo "------------ Finished OpenWRT Packages ---------------"

    if [ -e  $PIRATEBOX_FOLDER/share/board/init_done ] ; then
       echo "init_done file Found in Kareha folder. Won't reinstall board."
       exit 0;
    fi

    echo "  Wgetting kareha-zip file "
    cd $PIRATEBOX_FOLDER/tmp
    wget http://wakaba.c3.cx/releases/kareha_3.1.4.zip 
    if [ "$?" != "0" ] ; then
       echo "wget kareha failed.. you can place the current file your to  $PIRATEBOX_FOLDER/tmp "
    fi

    if [ -e  $PIRATEBOX_FOLDER/tmp/kareha* ] ; then
       echo "Kareha Zip found..."
    else 
       echo "No Zip found, abort "
       exit 255
    fi
    
    /usr/local/bin/unzip kareha_* 
    mv kareha/* $PIRATEBOX_FOLDER/share/board 
    rm  -rf $PIRATEBOX_FOLDER/tmp/kareha* 
    
    cd  $PIRATEBOX_FOLDER/share/board  
    cp -R  mode_image/* ./   
    cp  $PIRATEBOX_FOLDER/src/kareha_img_config.pl $PIRATEBOX_FOLDER/share/board/config.pl 
    chown -R $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/share/board   
    #Install filetype thumbnails
    mv $PIRATEBOX_FOLDER/share/board/extras/icons  $PIRATEBOX_FOLDER/share/board/ 

    #Activate on mainpage
    mv $PIRATEBOX_FOLDER/src/forum_kareha.html  $WWW_FOLDER/forum.html

    echo "Errors in chown occurs if you are using vfat on the USB stick"
    echo "   . don't Panic!"
    echo "Generating index page"
    wget http://127.0.0.1/board/kareha.pl -q 
    echo "finished!"
    echo "Now Edit your kareha settings file to change your ADMIN_PASS and SECRET : "
    echo "  # vi /opt/piratebox/www/board/config.pl "

    touch  $PIRATEBOX_FOLDER/share/board/init_done
fi

