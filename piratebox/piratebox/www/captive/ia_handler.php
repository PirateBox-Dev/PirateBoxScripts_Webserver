<?php
// general handler to give answers to "internet available checks"
//
// GPL3 (C) 2017 Matthias Strubel <matthias.strubel@aod-rpg.de>
//
//   $_SERVER['REMOTE_ADDR']  -  Clients IP
//   $_SERVER['REQUEST_URI']  - URL , needed for Client OS
//   $_SERVER['HTTP_USER_AGENT'] -  needed for Client OS verification
//   ( $_SERVER['SERVER_NAME'] - possibly )
//
// For Redirect:
//  $_ENV['PIRATEBOX_HOSTNAME']

require_once ("captive.func.php");



$config = get_config();

if ( isset ($_GET['enter'] ) ) {
    $enter_url=$config['enter_url'];

    header('Location: '.$enter_url, true, 302);
    count_ip($_SERVER['REMOTE_ADDR'],"no",99);
    erdebug (" ~~~ ENTER - $enter_url". $_SERVER['REMOTE_ADDR'] );

    exit;
} elseif ( isset ($_GET['enter_iOS'] )) {
    $enter_url=$config['enter_url_iOS'];

    header('Location: '.$enter_url, true, 302);
    count_ip($_SERVER['REMOTE_ADDR'],"no",99);
    erdebug (" ~~~ ENTER - $enter_url". $_SERVER['REMOTE_ADDR'] );

    exit;
}


$send = check_ip_send_fake($_SERVER['REMOTE_ADDR']);

    erdebug('DEBUG LOG FOR IA_HANDLER');
    erdebug(" - SEND        - " . $send );
    erdebug(" - REMOTE_ADDR - ". $_SERVER['REMOTE_ADDR'] );
    erdebug(" - REQUEST_URI - ". $_SERVER['REQUEST_URI'] );
    erdebug(" - HTTP_USER_AGENT - ". $_SERVER['HTTP_USER_AGENT'] );
    erdebug(" - SERVER_NAME - ". $_SERVER['SERVER_NAME'] );

$client_type="none";

if ( preg_match ( '/CaptiveNetworkSupport/' ,$_SERVER['HTTP_USER_AGENT'] )) {
    $client_type="iOS_background";
} elseif ( "/hotspot-detect.html" == $_SERVER['REQUEST_URI'] ){
    $client_type="iOS_captiveBrowser";
} elseif ( "/generate204" == $_SERVER['REQUEST_URI'] ){
    $client_type="Android" ;
} elseif ( "/ncsi.txt" == $_SERVER['REQUEST_URI'] ){
    $client_type="MSphone";
} elseif ( "/connecttest.txt" == $_SERVER['REQUEST_URI'] ){
    $client_type="MSWin10";
}

erdebug( "Detected client type: $client_type");

if ( $send == 0 ) {
    // Send redirect
    erdebug( " -> Send redirect");

    if ( preg_match ( '/iOS/' , $client_type )){
        header("Location: ". $config['captive_info_url_iOS'] , true, 302);
    } else {
        header("Location: ". $config['captive_info_url'] , true, 302);
    }
    count_ip($_SERVER['REMOTE_ADDR']);
    exit;
}
// Access confirmed, send fake reply
require_once ("captive.templates.php");
    erdebug( " -> Send answer");

call_user_func( "template_$client_type");
