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
    

    // smooth scrolling for internal links
    function filterPath(string) {
        return string
            .replace(/^\//,'')
            .replace(/(index|default).[a-zA-Z]{3,4}$/,'')
            .replace(/\/$/,'');
        }
        var locationPath = filterPath(location.pathname);
        var scrollElem = scrollableElement('html', 'body');
     
        $('a[href*=#]').each(function() {
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
	$('#shoutbox-input .message').val('');
}

function display_shoutbox() {
	refresh_shoutbox();
	refresh_time_sb();
}

function fnGetDomain(url) {
	return url.match(/:\/\/(.[^/]+)/)[1];
}