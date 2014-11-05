#
# Example config file.
#
# Uncomment and edit the options you want to specifically change from the
# default values. You must specify ADMIN_PASS and SECRET.
#

# System config
#use constant ADMIN_PASS => 'xyzPASSWORDzyx';	# Admin password. For fucks's sake, change this.
#use constant SECRET => 'xyzSECRETCODEzyx';		# Cryptographic secret. CHANGE THIS to something totally random, and long.
#use constant CAPPED_TRIPS => ('!!example1'=>' capcode','!!example2'=>' <em>cap</em>');	# Admin tripcode hash, for startng threads when locked down, and similar. Format is '!trip'=>'capcode', where 'capcode' is what is shown instead of the trip. This can contain HTML, but keep it valid XHTML!

# Page look
use constant TITLE => 'PirateBox board';	# Name of this image board
use constant SHOWTITLETXT => 1;				# Show TITLE at top (1: yes  0: no)
use constant SHOWTITLEIMG => 1;				# Show image at top (0: no, 1: single, 2: rotating)
use constant TITLEIMG => '/piratebox-logo-small.png';			# Title image (point to a script file if rotating)
#use constant THREADS_DISPLAYED => 10;			# Number of threads on the front page
#use constant THREADS_LISTED => 40;				# Number of threads in the thread list
#use constant REPLIES_PER_THREAD => 10;			# Replies shown
#use constant S_ANONAME => 'Anonymous';			# Defines what to print if there is no text entered in the name field
#use constant DEFAULT_STYLE => 'Futaba';		# Default CSS style title
use constant FAVICON => '/favicon.ico';			# Path to the favicon for the board

# Limitations
use constant ALLOW_TEXT_THREADS => 1;			# Allow users to create text threads
use constant ALLOW_TEXT_REPLIES => 1;			# Allow users to make text replies
#use constant AUTOCLOSE_POSTS => 0;				# Maximum number of posts before a thread closes. 0 to disable.
#use constant AUTOCLOSE_DAYS => 0;				# Maximum number of days with no activity before a thread closes. 0 to disable.
#use constant AUTOCLOSE_SIZE => 0;				# Maximum size of the thread HTML file in kilobytes before a thread closes. 0 to disable.
#use constant MAX_RES => 20;					# Maximum topic bumps
#use constant MAX_THREADS => 0;					# Maximum number of threads - set to 0 to disable
#use constant MAX_POSTS => 500;					# Maximum number of posts - set to 0 to disable
#use constant MAX_MEGABYTES => 0;				# Maximum size to use for all images in megabytes - set to 0 to disable
#use constant MAX_FIELD_LENGTH => 100;			# Maximum number of characters in subject, name, and email
#use constant MAX_COMMENT_LENGTH => 8192;		# Maximum number of characters in a comment
#use constant MAX_LINES_SHOWN => 15;			# Max lines of a comment shown on the main page (0 = no limit)
#use constant ALLOW_ADMIN_EDIT => 0;			# Allow editing of include files and spam.txt from admin.pl.
                                    			# Warning! This is a security risk, since include templates can run code! Only enable if you completely trust your moderators!

# Image posts
#use constant ALLOW_IMAGE_THREADS => 1;			# Allow users to create image threads
#use constant ALLOW_IMAGE_REPLIES => 1;			# Allow users to make image replies
#use constant IMAGE_REPLIES_PER_THREAD => 0;	# Number of image replies per thread to show, set to 0 for no limit.
use constant MAX_KB => 10000;					# Maximum upload size in KB
#use constant MAX_W => 200;						# Images exceeding this width will be thumbnailed
#use constant MAX_H => 200;						# Images exceeding this height will be thumbnailed
#use constant THUMBNAIL_SMALL => 1;				# Thumbnail small images (1: yes, 0: no)
#use constant THUMBNAIL_QUALITY => 70;			# Thumbnail JPEG quality
 use constant ALLOW_UNKNOWN => 0;				# Allow unknown filetypes (1: yes, 0: no)
 use constant MUNGE_UNKNOWN => '.unknown';		# Munge unknown file type extensions with this. If you remove this, make sure your web server is locked down properly.
 use constant FORBIDDEN_EXTENSIONS => ('php','php3','php4','phtml','shtml','cgi','pl','pm','py','r','exe','dll','scr','pif','asp','cfm','jsp','vbs'); # file extensions which are forbidden
 use constant STUPID_THUMBNAILING => 1;			# Bypass thumbnailing code and just use HTML to resize the image. STUPID, wastes bandwidth. (1: enable, 0: disable)
#use constant MAX_IMAGE_WIDTH => 16384;			# Maximum width of image before rejecting
#use constant MAX_IMAGE_HEIGHT => 16384;		# Maximum height of image before rejecting
#use constant MAX_IMAGE_PIXELS => 50000000;		# Maximum width*height of image before rejecting
#use constant CONVERT_COMMAND => 'convert';		# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)

# Captcha
#use constant ENABLE_CAPTCHA => 0;				# Enable verification codes (0: disabled, 1: enabled)
#use constant CAPTCHA_HEIGHT => 18;				# Approximate height of captcha image
#use constant CAPTCHA_SCRIBBLE => 0.2;			# Scribbling factor
#use constant CAPTCHA_SCALING => 0.15;			# Randomized scaling factor
#use constant CAPTCHA_ROTATION => 0.3;			# Randomized rotation factor
#use constant CAPTCHA_SPACING => 2.5;			# Letter spacing

# Tweaks
#use constant CHARSET => 'utf-8';				# Character set to use, typically "utf-8" or "shift_jis". Remember to set Apache to use the same character set for .html files! (AddCharset shift_jis html)
#use constant PROXY_CHECK => ();				# Ports to scan for proxies - NOT IMPLEMENTED.
#use constant TRIM_METHOD => 0;					# Which threads to trim (0: oldest - like futaba 1: least active - furthest back)
#use constant REQUIRE_THREAD_TITLE => 0;		# Require a title for threads (0: no, 1: yes)
#use constant DATE_STYLE => 'futaba';			# Date style ('2ch', 'futaba', 'localtime, 'http')
 use constant DISPLAY_ID => 'day';					# How to display user IDs (0 or '': don't display,
												#  'day', 'thread', 'board' in any combination: make IDs change for each day, thread or board,
												#  'mask': display masked IP address (similar IPs look similar, but are still encrypted)
												#  'sage': don't display ID when user sages, 'link': don't display ID when the user fills out the link field,
												#  'ip': display user's IP, 'host': display user's host)
#use constant EMAIL_ID => 'Heaven';				# Replace the ID with this string when the user uses an email. Set to '' to disable.
#use constant SILLY_ANONYMOUS => '';			# Make up silly names for anonymous people (same syntax as DISPLAY_ID)
#use constant FORCED_ANON => 0;					# Force anonymous posting (0: no, 1: yes)
#use constant TRIPKEY => '!';					# This character is displayed before tripcodes
#use constant ALTERNATE_REDIRECT => 0;			# Use alternate redirect method. (Javascript/meta-refresh instead of HTTP forwards.)
#use constant APPROX_LINE_LENGTH => 150;		# Approximate line length used by reply abbreviation code to guess at the length of a reply.
#use constant COOKIE_PATH => 'root';			# Path argument for cookies ('root': cookies apply to all boards on the site, 'current': cookies apply only to this board, 'parent': cookies apply to all boards in the parent directory) - does NOT apply to the style cookie!
#use constant STYLE_COOKIE => 'wakabastyle';	# Cookie name for the style selector.
#use constant ENABLE_DELETION => 1;				# Enable user deletion of posts. (0: no, 1: yes)
#use constant PAGE_GENERATION => 'paged';		# Page generation method ('single': just one page, 'paged': split into several pages like futaba, 'monthly': separate pages for each month)
#use constant DELETE_FIRST => 'remove';			# What to do when the first post is deleted ('keep': keep the thread, 'single': delete the thread if there is only one post, 'remove': delete the whole thread)
#use constant DEFAULT_MARKUP => 'waka';			# Default markup format ('none', 'waka', 'html', 'aa')
#use constant FUDGE_BLOCKQUOTES => 1;			# Modify formatting for old stylesheets
#use constant USE_XHTML => 1;					# Send pages as application/xhtml+xml to browsers that support this (0:no, 1:yes)
#use constant KEEP_MAINPAGE_NEWLINES => 0;		# Don't strip whitespace from main page (needed for Google ads to work, 0:no, 1:yes)
#use constant SPAM_TRAP => 1;					# Enable the spam trap (empty, hidden form fields that spam bots usually fill out) (0:no, 1:yes)

# Internal paths and files - might as well leave this alone.
#use constant RES_DIR => 'res/';				# Reply cache directory (needs to be writeable by the script)
#use constant CSS_DIR => 'css/';				# CSS file directory
#use constant IMG_DIR => 'src/';				# Image directory (needs to be writeable by the script)
#use constant THUMB_DIR => 'thumb/';			# Thumbnail directory (needs to be writeable by the script)
#use constant INCLUDE_DIR => 'include/';		# Include file directory
#use constant LOG_FILE => 'log.txt';			# Log file (stores delete passwords and IP addresses in encrypted form)
#use constant PAGE_EXT => '.html';				# Extension used for board pages after first
#use constant HTML_SELF => 'index.html';		# Name of main html file
#use constant HTML_BACKLOG => '';				# Name of backlog html file
#use constant RSS_FILE => '';					# RSS file. Set to '' to disable RSS support.
#use constant JS_FILE => 'kareha.js';			# Location of the js file
#use constant SPAM_FILES => ('spam.txt');		# Spam definition files, as a Perl list.
                                                # Hints: * Set all boards to use the same file for easy updating.
                                                #        * Set up two files, one being the official list from
                                                #          http://wakaba.c3.cx/antispam/spam.txt, and one your own additions.

# Admin script options
#use constant ADMIN_SHOWN_LINES => 5;				# Number of post lines the admin script shows.
#use constant ADMIN_SHOWN_POSTS => 10;				# Number of posts per thread the admin script shows.
#use constant ADMIN_MASK_IPS => 0;					# Mask poster IP addresses in the admin script (0: no, 1: yes)
#use constant ADMIN_EDITABLE_FILES => (SPAM_FILES); # A Perl list of all files that can be edited from the admin script.
                                                    # Hints: * If you don't trust your moderators, don't let them edit templates!
                                                    #          Templates can execute code on your server!
                                                    #        * If you still want to allow editing of templates, use
                                                    #          (SPAM_FILES,glob("include/*")) as a convenient shorthand.
#use constant ADMIN_BAN_FILE => '.htaccess';		# Name of the file to write bans to
#use constant ADMIN_BAN_TEMPLATE => "\n# Banned at <var scalar localtime> (<var \$reason>)\nDeny from <var \$ip>\n";
													# Format of the ban entries, using the template syntax.


# Icons for filetypes - file extensions specified here will not be renamed, and will get icons
# (except for the built-in image formats). These example icons can be found in the extras/ directory.
 use constant FILETYPES => (
#   # Audio files
 	mp3 => 'icons/audio-mp3.png',
 	ogg => 'icons/audio-ogg.png',
 	aac => 'icons/audio-aac.png',
 	m4a => 'icons/audio-aac.png',
 	mpc => 'icons/audio-mpc.png',
 	mpp => 'icons/audio-mpp.png',
 	mod => 'icons/audio-mod.png',
 	it => 'icons/audio-it.png',
 	xm => 'icons/audio-xm.png',
 	fla => 'icons/audio-flac.png',
 	flac => 'icons/audio-flac.png',
 	sid => 'icons/audio-sid.png',
 	mo3 => 'icons/audio-mo3.png',
 	spc => 'icons/audio-spc.png',
 	nsf => 'icons/audio-nsf.png',
 	# Archive files
 	zip => 'icons/archive-zip.png',
 	rar => 'icons/archive-rar.png',
 	lzh => 'icons/archive-lzh.png',
 	lha => 'icons/archive-lzh.png',
 	gz => 'icons/archive-gz.png',
 	bz2 => 'icons/archive-bz2.png',
 	'7z' => 'icons/archive-7z.png',
 	# Other files
 	swf => 'icons/flash.png',
 	torrent => 'icons/torrent.png',
 	# To stop Wakaba from renaming image files, put their names in here like this:
# 	gif => '.',
#	jpg => '.',
#	png => '.',
);

# Allowed HTML tags and attributes. Sort of undocumented for now, but feel free to
# learn by example.
#use constant ALLOWED_HTML => (
#	'a'=>{args=>{'href'=>'url'},forced=>{'rel'=>'nofollow'}},
#	'b'=>{},'i'=>{},'u'=>{},'sub'=>{},'sup'=>{},
#	'em'=>{},'strong'=>{},
#	'ul'=>{},'ol'=>{},'li'=>{},'dl'=>{},'dt'=>{},'dd'=>{},
#	'p'=>{},'br'=>{empty=>1},'blockquote'=>{},
#);


1;
