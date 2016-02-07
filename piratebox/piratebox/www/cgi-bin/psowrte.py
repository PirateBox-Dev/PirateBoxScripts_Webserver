#!/usr/bin/python

# PyShoutOut by Joey C. (http://www.joeyjwc.x3fusion.com)
# Writes the recieved information to the data file.
import cgi
from psogen import process_form


print "Content-type:text/html\r\n\r\n"

values = cgi.FieldStorage()
if "name" in values:
    rawname = values["name"].value
else:
    rawname = "&nbsp;"
if "data" in values:
    rawdata = values["data"].value
else:
    rawdata = "&nbsp;"

color = values["color"].value
timestamp = float(values["timestamp"].value)

process_form(rawname, rawdata, color, timestamp)

print "Status:200\r\n\r\n" 
print """<html><body>ok</body></html>"""
