#!/usr/bin/python

# Modificated ShoutBox Library    (C)2013-2014
#   enables further modifications for the ShoutBox
#   Run without to generate htmlfile
#   Run the following to enter a new line from command line
#     psogen.py input Anonymous default "Text"

import os
import datetime
import re
import messages
import broadcast


datafilename = os.environ["SHOUTBOX_CHATFILE"]
htmlfilename = os.environ["SHOUTBOX_GEN_HTMLFILE"]
clienttimestamp = os.environ["SHOUTBOX_CLIENT_TIMESTAMP"]

try:
    raw_dest = os.environ["SHOUTBOX_BROADCAST_DESTINATIONS"]
    finished_dest = re.sub('#', '"', raw_dest)
    broadcast_destination = eval(finished_dest)
except KeyError:
    broadcast_destination = False


def html_escape(text):
    """
    Removes HTML chars from the given text and replace them with HTML entities.
    """
    html_escape_table = {
        '"': "&quot;", "'": "&apos;", ">": "&gt;",
        "<": "&lt;"}
    return "".join(html_escape_table.get(c, c) for c in text)


def generate_html(content):
    """
    Generates Shoutbox-HTML-Frame...

    Args:
        content: String containing preformatted data
    """
    htmlstring = "<html><head><meta http-equiv='cache-control' content=" \
                 "'no-cache'><meta name='GENERATOR' content='PyShoutOut'>" \
                 "<title>Shout-Out Data</title><body>"
    htmlstring += content
    htmlstring += "</body></html>"
    return htmlstring


def generate_html_into_file(content):
    """
    Generates HTML Data based on given content  and write it to static html
    file.

    Args:
        content: String containing preformatted data
    """
    htmlstring = generate_html(content)
    htmlfile = open(htmlfilename, 'w')
    htmlfile.write(htmlstring)
    htmlfile.close()


def generate_html_from_file():
    """
    Generates HTML Data based on datafilename's content
    """
    old = read_data_file()
    generate_html_into_file(old)


def generate_html_to_display_from_file():
    """
    Generates and Displays generated HTML
    """
    old = read_data_file()
    htmlstring = generate_html(old)
    print htmlstring


def read_data_file():
    """
    Reads Data file from datafilename given name
    """
    datafile = open(datafilename, 'r')
    old = datafile.read()
    datafile.close()
    return old


def process_form(name, indata, color, timestamp):
    """
    Function for saving new Shoubox-Content & Regenerate static
    HTML file.
    -> usually called by HTML-Form
    """
    content = save_input(name, indata, color, timestamp)

    if not broadcast_destination:
        generate_html_into_file(content)


def save_input(name, indata, color, timestamp):
    """
    Acutally saves SB-Content to datafile
    """
    content = prepare_line(name, indata, color, timestamp)

    if broadcast_destination:
        return writeToNetwork(content, broadcast_destination)
    else:
        return writeToDisk(content)


def writeToNetwork(content, broadcast_destination):
    message = messages.shoutbox_message()
    message.set(content)
    casting = broadcast.broadcast()
    casting.setDestination(broadcast_destination)
    casting.set(message.get_message())
    casting.send()


def writeToDisk(content):
    old = read_data_file()
    finalcontent = content + old
    datafile = open(datafilename, 'r+')
    datafile.write(finalcontent)
    #datafile.truncate(0)
    datafile.close()
    return finalcontent


def prepare_line(name, indata, color, timestamp):
    name = html_escape(name)
    data = html_escape(indata)
    color = html_escape(color)
    if clienttimestamp == 'yes':
        curdate = datetime.datetime.fromtimestamp(timestamp)
    else:
        curdate = datetime.datetime.now()
    # Trying to make it look like this:
    # <div class="message">
    #     <date>00:00:00</date> <name>Nickname:</name> <data class="def">
    #        Lorem ipsum dolor sit amet</data>
    # </div>
    #
    content = "<div class='message'><date>%s</date> <name>%s:</name> " \
              "<data class='%s'>%s</data></div>\n" \
              % (curdate.strftime("%H:%M:%S"), name, color, data)
    return content

#--------------
#  Testing or Generating static HTML File
#--------------
if __name__ == "__main__":
    import sys
    if sys.argv.count("input") >= 1:
        save_input(sys.argv[2], sys.argv[3], sys.argv[4])
        generate_html_to_display_from_file()
        print "Entered Text."

    generate_html_from_file()
    print "Generated HTML-Shoutbox File."
