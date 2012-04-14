#!/usr/bin/python

# PyShoutOut by Joey C. (http://www.joeyjwc.x3fusion.com)
# Writes the recieved information to the data file.


import cgi, datetime, os, re
print "Content-type:text/html\r\n\r\n"
datafile = open("cgi-bin/data.pso", 'r+')
values = cgi.FieldStorage()
if values.has_key("name"):
  name = values["name"].value
else:
  name = "&nbsp;"
if values.has_key("data"):
  rawdata = values["data"].value
else:
  rawdata = "&nbsp;"
datapass = re.sub("<", "&lt;", rawdata)
data = re.sub(">", "&gt;", datapass)
color = values["color"].value
curdate = datetime.datetime.now()
old = datafile.read()
datafile.truncate(0)
datafile.close()
datafile = open("cgi-bin/data.pso", 'r+')
datafile.write("<date>" + curdate.strftime("%H:%M:%S") + "</date>&nbsp;&nbsp;<name>" + name + ":</name>&nbsp;&nbsp;&nbsp;<data class='" + color + "'>" + data + "</data><br>\n" + old)
datafile.close()
print """<html><head><meta http-equiv="refresh" content="0;url=/cgi-bin/psoread.py"></head><body>Reading...</body></html>"""
