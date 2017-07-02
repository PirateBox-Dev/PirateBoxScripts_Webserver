<?php

//Templates for generating correct answers on internet detection
//
// GPL3 (c)2017 Matthias Strubel matthias.strubel@aod-rpg.de

function template_iOS_background(){
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
	<TITLE>Success</TITLE>
</HEAD>
<BODY>
Success
</BODY>
</HTML>
<?php
}

function template_iOS_captiveBrowser(){
    header('Location: http://'.$config['hostname'].'/', true, 302);
}

function template_Android(){
    http_response_code(204);
}

function template_MSphone(){
    print ("Microsoft NCSI");
}

function template_MSWin10(){
    print ("Microsoft Connect Test");
}

function template_none(){
    print ("<html><body><pre>");
    print ("Not defined, but OK.");
    print ("Report the following to piratebox.cc: ");
    print (" - REMOTE_ADDR - ". $_SERVER['REMOTE_ADDR'] );
    print (" - REQUEST_URI - ". $_SERVER['REQUEST_URI'] );
    print (" - HTTP_USER_AGENT - ". $_SERVER['HTTP_USER_AGENT'] );
    print (" - SERVER_NAME - ". $_SERVER['SERVER_NAME'] );
    print ("</pre></body></html>");
}
