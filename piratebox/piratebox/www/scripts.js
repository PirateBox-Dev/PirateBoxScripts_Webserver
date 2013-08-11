$(document).ready(function() {
   	// do stuff when DOM is ready
   	$.get('forum.html', function(data) {
        $('div#forum_link').html(data);
    });
   	
   	$.get('forban_link.html', function(data) {
        $('div#forban_link').html(data);
    });
	
	$.get('station_cnt.txt', function(data) {
        $('div#station').html(data);
    });
   	
   	$('div#shoutbox').ajaxError(function() {
        $(this).text( "Triggered ajaxError handler on shoutbox" );
    });
	
	$("#sb_form").submit(function(event) {
	    /* stop form from submitting normally */
        event.preventDefault();
	    post_shoutbox();
    });

    display_shoutbox();
});

function refresh_shoutbox () {
    $.get('chat_content.html', function(data) {
   		$('div#shoutbox').html(data);
   	});
}
  
function refresh_time_sb () {
    // Refresh rate in milli seconds
    mytime=setTimeout('display_shoutbox()', 10000);
}

function post_shoutbox () {
	$.post("/cgi-bin/psowrte.py" , $("#sb_form").serialize())
	.success(function() { 
		refresh_shoutbox(); 
	});
	$('#shoutbox_message').val('');
}

function display_shoutbox() {
	refresh_shoutbox();
	refresh_time_sb();
}

function fnGetDomain(url) {
	return url.match(/:\/\/(.[^/]+)/)[1];
}