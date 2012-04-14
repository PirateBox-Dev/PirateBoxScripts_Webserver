#!/bin/sh
## PirateBox installer script  v.01
##  created by Matthias Strubel   2011-08-04
##

# All Perl packages for kareha
OPENWRT_PACKAGES_IMAGEBOARD=(  perl perlbase-base perlbase-cgi perlbase-essential perlbase-file perlbase-bytes perlbase-config perlbase-data perlbase-db-file perlbase-digest perlbase-encode perlbase-encoding perlbase-fcntl perlbase-gdbm-file perlbase-integer perlbase-socket perlbase-unicode perlbase-utf8 perlbase-xsloader  )



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
    mkdir -p $PIRATEBOX_FOLDER/forumspace
    chmod a+rw -R  $PIRATEBOX_FOLDER/forumspace
    echo "Copied the file. Now edit conf/piratebox.conf and uncomment #FORUM_LINK_HTML "
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

    for package in ${OPENWRT_PACKAGES[@]}
       do
         echo "Start install package $package ...."
         opkg -d piratebox install $package
         if [ $? ne 0 ] ; then
               echo "ERROR installing $package"
               exit 5
         fi
      done
    fi

    cd  $PIRATEBOX_FOLDER/share/board
    cp -R  mode_image/* ./ 
    cp  $PIRATEBOX_FOLDER/src/kareha_img_config.pl $PIRATEBOX_FOLDER/share/board/config.pl
    chown -R $LIGHTTPD_USER:$LIGHTTPD_GROUP  $PIRATEBOX_FOLDER/share/board 
    #Install filetype thumbnails
    mv $PIRATEBOX_FOLDER/share/board/extras/icons  $PIRATEBOX_FOLDER/share/board/
fi

