<?php
// CLI interface to captive.func.php
//
// GPL3 (c) 2017 , Matthias Strubel <matthias.strubel@aod-rpg.de>

if ( ! ( isset ( $argv['1'] ) &&
         isset ( $argv['2'] ) ) ) {
         die("
Add and removes IPs to captive.sqlite database

Usage:
   captive_cli.php <action> <ip>  (path)

   action = add / del
   ip     = valid ip address
   path   = optional, path to /opt/piratebox base folder
");
}

$action = $argv[1];
$ip   = $argv[2] ;

if ( isset ( $argv[3] )) {
    $path = $argv[3] ;
} else {
    $path = "";
}

require_once ( $path.'./www/captive/captive.func.php');

if ( $action == "add" ) {
    count_ip("$ip" , "yes" );
    exit ;
} elseif ( $action == "del" ) {
    del_ip("$ip" );
    exit ;
} elseif ( $action == "old" ) {
    // Refresh or relogin
    $config = get_config();
    if ( $config['old_triggers_login'] ) {
        del_ip("$ip" );
        count_ip("$ip" , "yes" );
    }
    exit;
} else {
    die ("unknown action");
}


