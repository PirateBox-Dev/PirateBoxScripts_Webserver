#!/usr/bin/python
"""
Script: Forest, a simple Python forum script.
Author: Andrew Nelis (andrew.nelis@gmail.com)
OnTheWeb: http://www.triv.org.uk/~nelis/forest
Date: Jun 2010
Version: 1.0.3

A Python CGI script for a basic flat-file based forum.

Getting Started:

* Set up your web server/place forest.py so that it is executed as a CGI script.
  You'll probably have to change the python path at the top of this script and
  chmod this script as appropriate if you're not on Windows.
* Put the stylesheet forest.css somewhere where it will be served by the
  webserver.
* Edit some of the variables below to taste. Most important of all:
    o DATA_PATH - Should point to a writable folder where the posts will be
                  stored.
    o CSS_PATH - Specify where the stylesheet forest.css is.
  (There are other settings within this file, mostly self explanatory.)
* Go to the appropriate URL and post away!

LICENCE:

Copyright (c) 2010 Andrew Nelis

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
"""


import md5
import os
import time

# Show any errors on the page. You might want to take this out on a live server
# and look in the servers error log instead.
#  Removed for compatibility issues
#import cgitb
#cgitb.enable()

# ============================================================================
# Configuration
# ============================================================================

# Where the threads are stored. This folder must exist.
DATA_PATH = '/opt/piratebox/share/forumspace/'
#Where the forest CGI is located (as a URL).
CGI_URL='/cgi-bin/forest.py'
# Where the main stylesheet is kept (as a URL).
CSS_PATH = '/content/css/forest.css'
# What is the title of the board?
BOARD_TITLE = 'PirateBox Board'
# Simple Description of the board, appears at the top of each page
BOARD_DESCRIPTION = """PirateBox Board. Put media reviews or questions here.<br>
<A HREF="http://piratebox.lan">Click here to go back to the main site</a> """
# How dates are stored (see python time module for details)
DATE_FORMAT = '%d %b %Y %H:%M:%S'
# If no author name is given, then this is the default.
ANON_AUTHOR = 'Anonymous Coward'

# How many entries to show on the index?
INDEX_PAGE_SIZE = 20
# How many entries to show on the thread page?
THREAD_PAGE_SIZE = 20

# Maximum lengths for names, subjects and message bodies.
# (currently we chop them off without warning)
MAX_AUTHOR_LEN = 20
MAX_SUBJECT_LEN = 100
MAX_BODY_LEN = 10000

# ============================================================================
# HTML Elements.
# ============================================================================
HTML_TOP = '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>%s</title>
  <link rel="stylesheet" href="%s" type="text/css" />
  <script type="text/javascript">
  function show(elem_id) {
    elem = document.getElementById(elem_id);
    if (elem) elem.style.display = 'block';
  }
  </script>
 </head>
<body>
<h3>%s</h3>
<p class="board_description">%s</p>
''' % (BOARD_TITLE, CSS_PATH, BOARD_TITLE, BOARD_DESCRIPTION)

HTML_BOTTOM = '''
<p class="smallprint" >Powered by the <a href="http://www.triv.org.uk/~nelis/forest">Forest Python Board</a></font>
</body></html>'''
HTML_THREADS_TOP = '''<table width="95%" class="threads_table">
 <tr class="threads_header">
  <th width="60%">Subject</th><th>Author</th><th>Date</th><th>Replies</th><th>Last Reply</th>
 </tr>
'''
HTML_THREADS_ROW = '''
 <tr class="%s">
  <td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>
 </tr>
'''
HTML_NEW_THREAD = '''
<p><a href="javascript:show('hidden_form');">Start a new thread</a></p>
<div id="hidden_form">
<form method="post" action="?new=thread">
<p>Name: <input name="author" maxlength="%s"/></p>
<p>Subject: <input name="subject" maxlength="%s" size="80"/></p>
<p><textarea name="body" rows="10" cols="80"></textarea></p>
<p><input class="submit_button" type="submit" value="New Thread!"/></p>
</form>
</div>
''' % (MAX_AUTHOR_LEN, MAX_SUBJECT_LEN)

HTML_NEW_REPLY = '''
<p><a href="javascript:show('hidden_form')">Reply to this thread</a></p>
<div id="hidden_form">
<form method="post" action="?new=reply&amp;thread=%%s">
<p>Name: <input name="author" maxlength="%s"/></p>
<p><textarea name="body" rows="10" cols="80"></textarea></p>
<p><input class="submit_button" type="submit" value="Reply!"/></p>
</form>
</div>
''' % (MAX_AUTHOR_LEN,)

HTML_THREADS_BOTTOM = '</table>'
HTML_THREAD_TOP = '''
<table width="95%%" class="threads_table">
 <col width="15%%" />
 <col width="85%%" />
 <tr><td colspan="2"><a href="?">&lt;&lt; Main</a></td></tr>
 <tr class="thread_header"><td colspan="2">%s</td></tr>
'''
HTML_THREAD_ROW = '''
 <tr class="%s">
  <td valign="top"><b>%s</b><br/><small>%s</small></td>
  <td>%s</td>
 </tr>
'''
HTML_THREAD_BOTTOM = '''
</table>
'''

# ============================================================================
# Error messages
# ============================================================================

ERR_INVALID_THREAD = '<h3 class="error">Invalid Thread Specified</h3>'
ERR_NO_SUBJECT = '<h3 class="error">No Subject Given</h3>'
ERR_NO_BODY = '<h3 class="error">No body text!</h3>'

# ============================================================================
# Misc. globals
# ============================================================================

# No need to fiddle with these though.
ROW_STYLES = {0: 'thread_row', 1: 'thread_row_alt'}
INDEX_FILE = os.path.join(DATA_PATH, 'index.txt')
THREAD_PATH = DATA_PATH

# ============================================================================
# Function definitions
# ============================================================================

html_escape_table = {
        "&": "&amp;", '"': "&quot;", "'": "&apos;", ">": "&gt;",
        "<": "&lt;", ';': "&#59;", "/": "&#47;", '=': "&#61;",
        ":": "&#58;", '?': "&#63;", '!': "&#33;", '(': "&#40;",
        "{": "&#121;", "[": "&#91", "-": "&#45",
        }
    
def strip_html( text ):
    """Remove HTML chars from the given text and replace them with HTML
       entities. """
    return "".join(html_escape_table.get(c,c) for c in text  )


def process_body(body):
    """Process the message body e.g. for escaping smilies, HTML etc.
    ready for storing. We should then just be able to print the body out"""
    import re
    # Maximum body length.
    new_body = strip_html( body[:MAX_BODY_LEN] )
    new_body = new_body.replace('\n', '<br/>\n')
    # Turn (obvious) URLs into links.
#   new_body = url_re.sub(r'<a href="\1">\1</a>', new_body)
#    url_re = re.compile('(http://[\S\.]+)')
    return new_body.encode('string_escape')


def process_author(author):
    """Clean the author tag"""
    # Remove tabs and ensure a maximum length.
    new_author = strip_html( author[:MAX_AUTHOR_LEN] )
    return new_author.replace('\t', ' ')


def process_subject(subject):
    """Clean the subject line"""
    if ( subject is not None):
	return subject[:MAX_SUBJECT_LEN]
    else:
 	return "No Subject"	
	

def get_query_params():
    """Return the URL parameters as a dictionary.

    Writing our own simple version means we don't have to import the cgi module
    for every page (which noticeably slows down page viewing).
    """
    param_string = os.getenv('QUERY_STRING', '')
    params = param_string.split('&')
    param_dict = {}
    for param in params:
        if '=' in param:
            key, value = param.split('=', 1)
            param_dict[key] = value
        else:
            param_dict[param] = None
    return param_dict


def is_valid_hash(hash_string):
    """Ensure that <hash_string> is a proper hash representing an existing
    thread"""
    # Should be a string comprising of hex digits
    if not hash_string.isalnum():
        return False
    if not os.path.exists(os.path.join(THREAD_PATH, hash_string)):
        return False
    return True


def get_offset(args):
    """Get the page offset, validating or returning 0 if None or invalid."""
    offset = args.get('offset', '0')
    if offset.isdigit():
        return int(offset)
    else:
        return 0


def update_thread(author, subject=None, key=None):
    """Update the thread, creating a new thread if key is None. Returns the
    key (hash).

    author  - String, the name of the author.
    subject - String, the title of the thread.
    key     - String, the key to an existing thread to update.

    If <subject> is given, then it's assumed that we're starting a new thread
    and if <key> is given, then we should be updating an existing thread.
    """
    now = time.strftime(DATE_FORMAT)
    author = process_author(author)

    if key:
        row_hash = key
    else:
        row_hash = md5.new('%s%s%s' % (now, author, subject)).hexdigest()

    # Read the index of threads in.
    try:
        threads = file(INDEX_FILE, 'r').readlines()
    except IOError:
        # The file gets (re)created later on so there's no problem.
        threads = []

    new_threads = []

    # Index format:
    # hash, date, num_replies, last_reply, author, subject
    if not key:
        # A new thread, put at the top.
        new_threads.append('\t'.join(
                (row_hash, now, '0', '-', author, subject)))

    for thread in threads:
        if thread.startswith(row_hash):
            # insert the updated thread at the beginning.
            # (_ ignore last reply - we're setting it to now)
            _, date, num_replies, _, author, subject = \
                    thread.strip().split('\t')
            num_replies = str(int(num_replies) + 1)
            new_threads.insert(0, '\t'.join(
                (row_hash, date, num_replies, now, author, subject)))
        else:
            new_threads.append(thread.strip())

    # Overwrite the existing index with the updated index.
    threads = file(INDEX_FILE, 'w')
    threads.write('\n'.join(new_threads))
    threads.close()

    return row_hash


def new_subject(field_storage):
    """Add a new subject to the list of threads.

    field_storage - cgi.FieldStorage instance.

    On success:
        returns <new subject hash string>
    On error:
        raises ValueError with error as message.
    """
    author = field_storage.getfirst( 'author', ANON_AUTHOR )
    subject = field_storage.getfirst( 'subject' )
    body = field_storage.getfirst( 'body' )
    if not subject:
        raise ValueError( ERR_NO_SUBJECT )
    elif not body:
        raise ValueError( ERR_NO_BODY )
    subject = strip_html(subject.replace('\t', ' '))
    row_hash = update_thread( author, subject )
    new_post( author, subject, body, row_hash )
    return row_hash


def new_post(author, subject, body, key):
    """Create a new post, either by creating or appending to a post file.

    author, subject, body, key - Strings
    """
    author = process_author(author)
    subject = process_subject(subject)
    body = process_body(body)

    date = time.strftime(DATE_FORMAT)
    post_filename = os.path.join(THREAD_PATH, key)
    if not os.path.exists(post_filename):
        post_file = file(post_filename, 'w')
        print >> post_file, '%s\t%s' % (key, subject)
    else:
        post_file = file(post_filename, 'a')
    print >> post_file, '%s\t%s\t%s' % (date, author, body)


def reply(field_storage, key):
    """Reply to an existing post.

    field_storage   - A cgi.FieldStorage containing post data for the post
    key - String, the id of the thread we're replying to.

    On success:
        return <thread key string>
    On failure:
        raise ValueError with error message as error value.
    """
    # Check that the thread id is valid.
    if not (key and is_valid_hash(key)):
        raise ValueError( ERR_INVALID_THREAD )
    author = field_storage.getfirst( 'author', ANON_AUTHOR )
    body = field_storage.getfirst( 'body' )
    if not body:
        raise ValueError( ERR_NO_BODY )
    author = author.replace('\t', ' ')
    update_thread(author, key=key)
    new_post(author, None, body, key)
    return key


def display_paging_links( current_offset, num_items, page_length, thread=None ):
    """Display a list of links to go to a given page number"""
    pages = num_items / page_length
    # Any left over pages?
    if (num_items % page_length):
        pages += 1

    if pages < 2:
        # Only one page. Don't bother showing links.
        return

    links = []
    if thread:
        url = '?thread=%s&offset=%%d' % thread
    else:
        url = '?offset=%d'
    for page_number in range(pages):
        offset = page_number * page_length
        if offset != current_offset:
            links.append( '<a href="%s">%s</a>' % \
                    (url % offset, page_number + 1) )
        else:
            links.append( str( page_number + 1 ) )

    print ' | '.join(links)


def list_threads(offset=0):
    """List the existing threads."""
    if os.path.exists(INDEX_FILE):
        thread_file = file(INDEX_FILE, 'r')
        threads = thread_file.read().strip().split('\n')
        thread_file.close()
    else:
        threads = []

    num_threads = len(threads)

    display_paging_links(offset, num_threads, INDEX_PAGE_SIZE)

    print HTML_THREADS_TOP

    thread_index = -1

    for thread in threads[offset:offset + INDEX_PAGE_SIZE]:
        thread_index += 1

        thread_items = thread.split('\t')
        if len(thread_items) != 6:
            continue

        thread_hash, date, num_replies, last_reply, author, subject = \
            thread_items

        link = '<a href="?thread=%s">%s</a>' % (thread_hash, subject)

        #  Date Author Subject Replies Last Reply
        print HTML_THREADS_ROW % (ROW_STYLES[thread_index % 2], link, author,
            date, num_replies, last_reply)

    print HTML_THREADS_BOTTOM
    print HTML_NEW_THREAD


def list_single_thread(thread_hash, offset=0):
    """Output the HTMl for a given thread id"""
    if not is_valid_hash(thread_hash):
        print ERR_INVALID_THREAD
        return

    thread_file = file(os.path.join(THREAD_PATH, thread_hash), 'r')
    threads = thread_file.read().split('\n')
    thread_file.close()

    # The first item in the file is actually the hash and the subject. But we
    # don't need it really.
    _, subject = threads.pop(0).split('\t')
    num_posts = len(threads)

    display_paging_links(offset, num_posts, THREAD_PAGE_SIZE, thread_hash)
    print HTML_THREAD_TOP % subject.strip()

    row_index = -1
    for line in threads[offset : offset + THREAD_PAGE_SIZE]:
        row_index += 1
        split_line = line.split('\t')
        if len(split_line) != 3:
            continue

        date, author, body = split_line
        print HTML_THREAD_ROW % (ROW_STYLES[row_index % 2], author, date,
            body.decode('string_escape'))

    print HTML_THREAD_BOTTOM
    print HTML_NEW_REPLY % thread_hash


def redirect( threadid, offset=None ):
    """Redirect the browser"""
    #new_location = os.environ.get('REQUEST_URI', '')
    new_location = CGI_URL
    new_location += '?thread=%s' % threadid
    if offset:
        new_location += '&offset=%s' % offset

## can't use standard redirect on CGIHTTPServer 
#    print 'Status: 303 See Other'
#    print 'Location: %s' % new_location
#    print
#    print 'Nothing to see here, move along!'

    print 'Content-Type: text/html; charset=utf-8'
    print
    print '<html><head><meta http-equiv="refresh" content="0;url=%s">' % new_location
    print "</head></html>"
	
def handle():
    """Main entry point for our code. Handles the web request."""

    query_params = get_query_params()
    post_error = None

    if query_params.has_key('new'):
        # We only want the whole cgi module when we need to parse POST data.
        import cgi
        form_data = cgi.FieldStorage()
        what = query_params['new']
        if what == 'thread':
            try:
                thread_hash = new_subject(form_data)
                redirect( thread_hash )
                return
            except ValueError, error:
                post_error = str( error )
        elif what == 'reply':
            try:
                thread_hash = reply(form_data, query_params.get('thread'))
                # QQQ -> Get offset.
                redirect( thread_hash )
                return
            except ValueError, error:
                post_error = str( error )

    print 'Content-Type: text/html; charset=utf-8'
    print
    print HTML_TOP

    if post_error:
        print post_error

    # paging.
    offset = get_offset( query_params )

    if query_params.has_key( 'thread' ):
        list_single_thread( query_params['thread'], offset )
    else:
        list_threads( offset )

    print HTML_BOTTOM


if __name__ == '__main__':
    handle()
