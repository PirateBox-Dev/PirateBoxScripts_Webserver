<?php
// general handler to give answers to "internet available checks"
//
// GPL3 (C) 2017 Matthias Strubel <matthias.strubel@aod-rpg.de>
//
//   $_SERVER['REMOTE_ADDR']  -  Clients IP


if ( $_SERVER['REMOTE_ADDR']  != '127.0.0.1' ) {
    echo "403";
    exit;
}

require_once ("captive.func.php");



$config = get_config();

$action = $_GET['type'];
$ip = $_GET['ip'];


if ( $action == "add" ) {
    count_ip("$ip" , "yes" );
    exit ;
} elseif ( $action == "show" ) {
	print_stats();
	exit;
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


?>
