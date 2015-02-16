#!/bin/bh

if [[ ! -d /opt/piratebox/share/board ]]; then
    echo "You have to install the imageboard first!"
    echo "Run (as root):"
    echo "\t/opt/piratebox/bin/install_piratebox.sh imageboard"
else
    echo -n "Imageboard admin password: "
    read -s BOARDPASSWORD
    echo
    sed -i "s|xyzPASSWORDzyx|$BOARDPASSWORD|g" /opt/piratebox/share/board/config.pl

    TEMPRAND=$(< /dev/urandom tr -dc A-Za-z0-9_ | head -c128)
    sed -i "s|xyzSECRETCODEzyx|$TEMPRAND|g" /opt/piratebox/share/board/config.pl

    sed -i "s|#use constant ADMIN_PASS|use constant ADMIN_PASS|" /opt/piratebox/share/board/config.pl
    sed -i "s|#use constant SECRET|use constant SECRET|" /opt/piratebox/share/board/config.pl
fi
