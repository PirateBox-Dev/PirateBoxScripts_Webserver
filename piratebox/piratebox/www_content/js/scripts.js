$(document).ready(function() {
	$.get('/station_cnt.txt', function(data) {
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

        $("#du_form").submit(function(event) {
            /* stop form from submitting normally */
        event.preventDefault();
        post_diskusage();
    });

    display_diskusage();
    display_shoutbox();

   // Add Tooltips
    if ( $('#du_form_button').lenght ) {
	    $('#du_form_button').tooltip();
    }

    // Spin menu icon and toggle nav
    $('#menu-icon').click(function() {
        $(this).toggleClass('rotate');
        $('#top-nav').slideToggle();
    });

    // Closes the mobile nav
    $('#top-nav a').click(function() {
        if ($('#top-nav').is(':visible') 
        && $('#menu-icon').is(':visible')) {
            $('#top-nav').slideUp();
            $('#menu-icon').toggleClass('rotate');
        }
    });

    // Hides the welcome
    $('#thanks').click(function() {
        $('#welcome').slideUp();
    });

    // Detects window size
    $(window).resize(function() {
        if ($('#menu-icon').is(':visible')) {
            $('#top-nav').hide();
        } else {
            $('#top-nav').show();
        }
    });
    
    post_diskusage();

    // smooth scrolling for internal links
    function filterPath(string) {
        return string
            .replace(/^\//,'')
            .replace(/(index|default).[a-zA-Z]{3,4}$/,'')
            .replace(/\/$/,'');
        }
        var locationPath = filterPath(location.pathname);
        var scrollElem = scrollableElement('html', 'body');
     
        $('a[href*=\\#]').each(function() {
            var thisPath = filterPath(this.pathname) || locationPath;
            if (  locationPath == thisPath
            && (location.hostname == this.hostname || !this.hostname)
            && this.hash.replace(/#/,'') ) {
                var $target = $(this.hash), target = this.hash;
                if (target) {
                    var targetOffset = $target.offset().top;
                    $(this).click(function(event) {
                        event.preventDefault();
                        $(scrollElem).animate({scrollTop: targetOffset}, 400, function() {
                            location.hash = target;
                        });
                    });
                }
            }
        });
     
    // use the first element that is "scrollable"
    function scrollableElement(els) {
        for (var i = 0, argLength = arguments.length; i <argLength; i++) {
            var el = arguments[i],
                $scrollElement = $(el);
            if ($scrollElement.scrollTop()> 0) {
                return el;
            } else {
                $scrollElement.scrollTop(1);
                var isScrollable = $scrollElement.scrollTop()> 0;
                $scrollElement.scrollTop(0);
                if (isScrollable) {
                    return el;
                }
            }
        }
        return [];
    }
});

function refresh_shoutbox () {
    $.get('/chat_content.html', function(data) {
   		$('div#shoutbox').html(data);
   	});
}
  
function refresh_time_sb () {
    // Refresh rate in milli seconds
    mytime=setTimeout('display_shoutbox()', 10000);
}

function post_shoutbox () {
        $("#send-button").prop('value', 'Sending...');
        $("#send-button").prop('disabled', true);

        $.post("/cgi-bin/psowrte.py" , $("#sb_form").serialize())
        .success(function() {
                refresh_shoutbox();
                $("#send-button").prop('value', 'Send')
                $("#send-button").prop('disabled', false);
        });
        $('#shoutbox-input .message').val('');
}

function display_shoutbox() {
	refresh_shoutbox();
	refresh_time_sb();
}

function refresh_diskusage() {
    $.get('/diskusage.html', function(data) {
                $('div#diskusage').html(data);
        });
}

function refresh_time_du () {
    // Refresh rate in milli seconds
    mytimedu=setTimeout('display_diskusage()', 10000);
}

function post_diskusage() {
	$("#du_form_button").prop('value', 'Refreshing...');
	$("#du_form_button").prop('disabled', true);

        $.post("/cgi-bin/diskwrite.py")
        .success(function() {
                refresh_diskusage();
            $("#du_form_button").prop('value', 'Refresh');
            $("#du_form_button").prop('disabled', false);
        });
        $('#diskusage-input .message').val('');


}

function display_diskusage() {
        refresh_diskusage();
        refresh_time_du();
}

function fnGetDomain(url) {
	return url.match(/:\/\/(.[^/]+)/)[1];
}
