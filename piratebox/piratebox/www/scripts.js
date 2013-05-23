function refresh() {
	$("#station_cnt").load("station_cnt.txt", function () {
		// There is no need to ask the user to refresh the page, as station_cnt will refresh itself.
		$("#station_cnt a").attr("title", ""); 
	});
}

$(document).ready(function () {
	refresh();
	// Every minute (station_cnt.txt refreshes every 2 minutes, but this way we are sure to have statistics which aren't too old)
	interval = window.setInterval( 'refresh()', 60000 ); 

	$.get('forum.html', function(data) {
		$('div#forum_link').html(data);
	});

	$.get('station_cnt.txt', function(data) {
		$('div#station').html(data);
	});

	$('div#shoutbox').ajaxError(function() {
	    $(this).text("Triggered ajaxError handler on shoutbox");
	});

	$('#sb_form').submit(function(event) {
		// stop form from submitting normally
		event.preventDefault();
		post_shoutbox();
	});
		
	display_shoutbox();
});

function refresh_shoutbox () {
	$.get('/cgi-bin/psoread.py', function(data) {
		$('div#shoutbox').html(data);
	});
}

function refresh_time_sb () {
	// Refresh rate in milliseconds
	mytime=setTimeout('display_shoutbox()', 10000);
}

function post_shoutbox () {
	$.post("/cgi-bin/psowrte.py" , $("#sb_form").serialize())
	.success(function() { 
		refresh_shoutbox(); 
	});
	$('#sb_form_text').val("");
}

function display_shoutbox() {
	refresh_shoutbox();
	refresh_time_sb();
}

function fnGetDomain(url) {
	return url.match(/:\/\/(.[^/]+)/)[1];
}