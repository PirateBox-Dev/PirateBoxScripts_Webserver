#!/bin/sh
## PirateBox installer script  
##  created by Matthias Strubel   (c)2011-2014 GPL-3
##

create_content_folder(){

   echo "Creating 'content' folder on USB stick and move over stuff"
   mkdir -p $WWW_CONTENT
   cp -r     $PIRATEBOX_FOLDER/www_content/*   $WWW_CONTENT

   [ ! -L $PIRATEBOX_FOLDER/www/content  ] && \
		ln -s $WWW_CONTENT  $WWW_FOLDER/content
   [ ! -e $WWW_FOLDER/favicon.ico ] && \
		ln -s $WWW_CONTENT/favicon.ico $WWW_FOLDER

   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_CONTENT -R
   chmod  u+rw $WWW_CONTENT
   return 0
}

# Load configfile

if [ -z  $1 ] || [ -z $2 ]; then 
  echo "Usage install_piratebox my_config <part>"
  echo "   Parts: "
  echo "       part2          : sets Permissions and links correctly"
  echo "       imageboard     : configures kareha imageboard with Basic configuration"
  echo "                        should be installed in <Piratebox-Folder>/share/board"
  echo "       pyForum        : Simple PythonForum"
  echo "       station_cnt        : Adds Statio counter to your Box - crontab entry"
  echo "       flush_dns_reg      : Installs crontask to flush dnsmasq regulary"
  echo "       hostname  'name'   : Exchanges the Hostname displayed in browser"
  exit 1
fi


if [ !  -f $1 ] ; then 
  echo "Config-File $1 not found..." 
  exit 1 
fi

#Load config
PIRATEBOX_CONFIG=$1
. $1 

if [ $2 = 'pyForum' ] ; then
    cp -v $PIRATEBOX_FOLDER/src/forest.py  $WWW_FOLDER/cgi-bin
    cp -v $PIRATEBOX_FOLDER/src/forest.css $WWW_FOLDER/content/css
    mkdir -p $PIRATEBOX_FOLDER/forumspace
    chmod a+rw -R  $PIRATEBOX_FOLDER/forumspace 2> /dev/null
    chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_FOLDER/cgi-bin/forest.py
    chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $WWW_FOLDER/content/forest.css  2> /dev/null
    echo "Copied the files. Recheck your PirateBox now. "
fi



if [ $2 = 'part2' ] ; then
   echo "Starting initialize PirateBox Part2.."
#Create directories 
#   mkdir -p $PIRATEBOX_FOLDER/share/Shared
   mkdir -p $UPLOADFOLDER
   mkdir -p $PIRATEBOX_FOLDER/share/board
   mkdir -p $PIRATEBOX_FOLDER/share/tmp
   mkdir -p $PIRATEBOX_FOLDER/tmp

   #Distribute the Directory Listing files
   if [ "$CUSTOM_DIRLIST_COPY" = "yes" ] ; then
       $PIRATEBOX_FOLDER/bin/distribute_files.sh $SHARE_FOLDER/Shared true
   fi
   #Set permissions
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/share -R
   chmod  u+rw $PIRATEBOX_FOLDER/share
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/www -R
   chmod u+x $PIRATEBOX_FOLDER/www/cgi-bin/* 
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/tmp
   chown $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/tmp -R


#Install a small script, that the link on the main page still works
   if  [ !  -f $PIRATEBOX_FOLDER/share/board/kareha.pl ] ; then  
      cp $PIRATEBOX_FOLDER/src/kareha.pl $PIRATEBOX_FOLDER/share/board
   fi
  
   [ ! -L $PIRATEBOX_FOLDER/www/board  ] && ln -s $PIRATEBOX_FOLDER/share/board $PIRATEBOX_FOLDER/www/board
   [ ! -L $PIRATEBOX_FOLDER/www/Shared ] && ln -s $UPLOADFOLDER  $PIRATEBOX_FOLDER/www/Shared
   [ ! -L $PIRATEBOX_FOLDER/www/content  ] && \
       ln -s $WWW_CONTENT  $WWW_FOLDER/content

fi 

#Install the image-board
if [ $2 = 'imageboard' ] ; then
   
    if [ -e  $PIRATEBOX_FOLDER/share/board/init_done ] ; then
       echo "$PIRATEBOX_FOLDER/share/board/init_done file Found in Kareha folder. Won't reinstall board."
       exit 0;
    fi

    
    cd $PIRATEBOX_FOLDER/tmp
    KAREHA_RELEASE=kareha_3.1.4.zip
    if [ ! -e $PIRATEBOX_FOLDER/tmp/$KAREHA_RELEASE ] ; then
	echo "  Wgetting kareha-zip file "
    	wget http://wakaba.c3.cx/releases/Kareha/$KAREHA_RELEASE
	if [ "$?" != "0" ] ; then
       		echo "wget kareha failed.. you can place the current file your to  $PIRATEBOX_FOLDER/tmp "
	 fi
    fi

    if [ -e  $PIRATEBOX_FOLDER/tmp/$KAREHA_RELEASE ] ; then
       echo "Kareha Zip found..."
    else 
       echo "No Zip found, abort "
       exit 255
    fi
    
    unzip $KAREHA_RELEASE
    mv kareha/* $PIRATEBOX_FOLDER/share/board 
    rm  -rf $PIRATEBOX_FOLDER/tmp/kareha* 
    
    cd  $PIRATEBOX_FOLDER/share/board  
    cp -R  mode_image/* ./   
    cp  $PIRATEBOX_FOLDER/src/kareha_img_config.pl $PIRATEBOX_FOLDER/share/board/config.pl 
    cp  $PIRATEBOX_FOLDER/src/no_forum.html  $PIRATEBOX_FOLDER/share/board/index.htm
    chown -R $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/share/board   
    #Install filetype thumbnails
    mv $PIRATEBOX_FOLDER/share/board/extras/icons  $PIRATEBOX_FOLDER/share/board/ 

    echo "Errors in chown occurs if you are using vfat on the USB stick"
    echo "   . don't Panic!"
    echo "Generating index page"
    cd /tmp
    wget -q http://127.0.0.1/board/kareha.pl 
    echo "finished!"
    echo "Now Edit your kareha settings file to change your ADMIN_PASS and SECRET : "
    echo "  # vi $PIRATEBOX_FOLDER/www/board/config.pl "

    touch  $PIRATEBOX_FOLDER/share/board/init_done
fi

if [ $2 = "station_cnt" ] ; then
    #we want to append the crontab, not overwrite
    crontab -l   >  $PIRATEBOX_FOLDER/tmp/crontab 2> /dev/null
    echo "#--- Crontab for PirateBox-Station-Cnt" >>  $PIRATEBOX_FOLDER/tmp/crontab
    echo " */2 * * * *    $PIRATEBOX_FOLDER/bin/station_cnt.sh >  $WWW_FOLDER/station_cnt.txt "  >> $PIRATEBOX_FOLDER/tmp/crontab
    crontab $PIRATEBOX_FOLDER/tmp/crontab
    [ "$?" != "0" ] && echo "an error occured" && exit 254
    $PIRATEBOX_FOLDER/bin/station_cnt.sh >  $WWW_FOLDER/station_cnt.txt
    echo "installed, now every 2 minutes your station count is refreshed"
fi

if [ $2 = "flush_dns_reg" ] ; then
    crontab -l   >  $PIRATEBOX_FOLDER/tmp/crontab 2> /dev/null
    echo "#--- Crontab for dnsmasq flush" >>  $PIRATEBOX_FOLDER/tmp/crontab
    echo " */2 * * * *    $PIRATEBOX_FOLDER/bin/flush_dnsmasq.sh >  $PIRATEBOX_FOLDER/tmp/dnsmasq_flush.log "  >> $PIRATEBOX_FOLDER/tmp/crontab
    crontab $PIRATEBOX_FOLDER/tmp/crontab
    [ "$?" != "0" ] && echo "an error occured" && exit 254
    echo "Installed crontab for flushing dnsmasq requlary"
fi

set_hostname() {
	local name=$1 ; shift;

	sed  "s|#####HOST#####|$name|g"  $PIRATEBOX_FOLDER/src/redirect.html.schema >  $WWW_FOLDER/index.html
        sed "s|HOST=\"$HOST\"|HOST=\"$name\"|" -i  $PIRATEBOX_CONFIG
}

if [ $2 = "hostname" ] ; then
	echo "Switching hostname to $3"
	set_hostname "$3"
	echo "..done"
fi

if [ $2 = "content" ] ; then
	create_content_folder
fi
