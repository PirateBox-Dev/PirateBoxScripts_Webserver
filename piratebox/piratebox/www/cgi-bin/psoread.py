#!/usr/bin/python

# PyShoutOut by Joey C. (http://www.joeyjwc.x3fusion.com)
# Read the data from a shout-out file.


# Changed by Matthias Strubel / 2011-02-27 for piratebox-path

css = open("cgi-bin/style.css", 'r')
data = open("cgi-bin/data.pso", 'r')
stl = css.read()
dat = data.read()
css.close()
data.close()
print "Content-type:text/html\r\n\r\n"
print "<html><head><meta name='GENERATOR' content='PyShoutOut'><title>Shout-Out Data</title><style type='text/css'>"
print stl
print "</style></head>"
print "<body>"
print dat
print "</body>"
