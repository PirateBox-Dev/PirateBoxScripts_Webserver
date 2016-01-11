#!/usr/bin/python

# Disk Write
# Writes the total freespace to an HTML file.

import cgi, datetime
from diskusage import get_usage


print "Content-type:text/html\r\n\r\n"

get_usage("/opt/piratebox/share/Shared/")

print """<html><body>ok</body></html>"""
