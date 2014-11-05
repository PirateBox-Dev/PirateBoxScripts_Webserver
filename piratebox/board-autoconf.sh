#!/usr/bin/bash

if [[ ! -d /opt/piratebox/share/board ]]; then
    echo "You have to install the imageboard first!"
    echo "Run (as root):"
    echo "\t/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf imageboard"
else
    echo -n "Imageboard admin password: "
    read -s BOARDPASSWORD
    echo
    sed -i "s|xyzPASSWORDzyx|$BOARDPASSWORD|g" /opt/piratebox/share/board/config.pl

    TEMPRAND=$(< /dev/urandom tr -dc A-Za-z0-9_ | head -c128)
    sed -i "s|xyzSECRETCODEzyx|$TEMPRAND|g" /opt/piratebox/share/board/config.pl
fi
