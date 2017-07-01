<?php
// Captive portal imitation database functions
//   - Create functions for initializing, adding and deleting entries.
//
// GPL3 (c) 2017 , Matthias Strubel <matthias.strubel@aod-rpg.de>



// SQLITE_FILE  ; SQLITE database, needs to be a PDO URI
// minimum_answers ; how much background requests needs to be issued
//                   for automatic "login"
// old_triggers_login ; 1 = a DHCP lease renew & rejoin should trigger
//                          captive portal
//                      0 = Only a worn out DHCP lease triggers the
//                          captive portal
//
function get_config(){
    $hostname="piratebox.lan";
    return  array (
     'SQLITE_FILE'         =>  "sqlite:/tmp/captive.sqlite" ,
     'minimum_answers'     => 5 ,
     'old_triggers_login'  => 0,
     'debug'               => 1,
     'hostname'            => "$hostname",
     'captive_info_page'   => "http://$hostname/content/welcome.html" ,
 );
}

// Perform database connect, create if not available.
// We assume that the sqlite database is always regenerated, because it is
// located in memory.
//
function __do_db_connect() {
    $config = get_config();
    if ( !  $db = new PDO(  $config['SQLITE_FILE'] ) ) {
        print_r (  $db->errorInfo() ) ;
            die ( "Error, couldn't open database " );
    }
    // $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $sth = $db->prepare( 'CREATE TABLE IF NOT EXISTS access ( ip text  PRIMARY KEY ASC, counter int )');
    if ( ! $sth->execute() )
              die ( "Error creating table: ". $sth->errorInfo ());

    return $db;
}

// Remove entry during release of the IP via dnsmasq
function del_ip($ip){
    $db=__do_db_connect();

    $del_stmt = $db->prepare( "DELETE from access WHERE ip = :ip ");
    if ( ! $del_stmt->execute( array ( ':ip' => $ip ) ) )  {
        die ( "Error deleting IP $ip");
    }
    return 0;
}

// Check if IP needs an captive portal answer,
//    or we are still sending redirect answers.
//
//    1 = Send fake reply
//    0 = Send redirect
function check_ip_send_fake($ip){
    $config = get_config();
    $db=__do_db_connect();
    $sel_sth= $db->prepare( "SELECT ip, counter FROM access WHERE ip = :ip ");
    if ( ! $sel_sth->execute( array ( ':ip' => $ip ) ) ) {
        die( "Error getting IP entry: " . $sel_sth->errorInfo());
    }

    $cnt    = 0;
    if ( $row = $sel_sth->fetch(PDO::FETCH_ASSOC)  ) {
        $cnt = $row['counter'];
    } else {
        $cnt = 0;
        // This should not happen, because we get an entry through dnsmasq
    }

    if ( $cnt > $config['minimum_answers'] ) {
        return 1;
    } else {
        return 0;
    }
}

// This function is controlling the IP entry in the database.
//
// It is called by dnsmasq to do the initial insert:
//     count_ip($ip, "yes");
//
// It is called by iac_handler.php via
//     count_ip($ip);
//
// And the enter.php for unlocking via captive browser
//     count_ip($ip,,"99");
//
function count_ip($ip, $do_only_insert="no" , $amount=1 ){
    $db=__do_db_connect();
    $insert="INSERT INTO access ( ip , counter ) VALUES ( :ip , :cnt ) ";
    $stmt="";
    $cnt = 0;
    if ( $do_only_insert == "no" ) {
        $sel_sth= $db->prepare( "SELECT ip, counter FROM access WHERE ip = :ip ");
        if ( ! $sel_sth->execute( array ( ':ip' => $ip ) ) ) {
            die( "Error getting IP entry: " . $sel_sth->errorInfo());
        }

        if ( $row = $sel_sth->fetch(PDO::FETCH_ASSOC)  ) {
            $cnt = $row['counter'] + $amount;
            $stmt= "UPDATE access SET counter = :cnt WHERE ip = :ip ";
        } else {
            $cnt = 0;
            $stmt=$insert;
            // This should not happen, because we get an entry through dnsmasq
        }

    } elseif ( $do_only_insert == "yes" ) {
        // This is used to avoid an additional select & update,
        // because dnsmasq is calling this before the client gets an IP.
        $stmt = $insert;
    } else {
        die ("unexpected function call with do_only_insert= $do_only_insert");
    }

    $up_stmt = $db->prepare( "$stmt" );
    if ( ! $up_stmt->execute ( array ( ':ip' => $ip , ':cnt' => $cnt ))) {
        die ("Error updating table with counter $cnt". $up_stmt->errorInfo ());
    }
    return 0;
}


function erdebug($string="") {
    $config=get_config();
    if (  $config['debug'] ) {
        error_log($string);
    }
}
?>
