#!/usr/bin/python

# Library to write the current disk usage

# Heavily Modified version the ShoutBox Library (psogen.py)

import os, re, datetime
from psutil import disk_usage

htmlfilename = os.environ["DISK_GEN_HTMLFILE"]
delay = 60*5 #In seconds

#--------------
#  Generates Shoutbox-HTML-Frame  ...
#           Imports:
#               content    -   String  containing preformatted data
#--------------
def generate_html(content):
	htmlstring =   "<html><head><meta http-equiv='cache-control' content='no-cache'><meta name='GENERATOR' content='disk usage'><title>DiskUsage Data</title></head><body>"
	htmlstring +=  content
	htmlstring +=  "</body></html>"
	return htmlstring

def modification_date(filename):
	moddate = os.path.getmtime(filename)
	return datetime.datetime.fromtimestamp(moddate)

#--------------
#   Generates HTML Data based on given content  and write it to static html file
#          Imports:
#               content    -   String  containing preformatted data
#--------------
def generate_html_into_file(content):
	open(htmlfilename, 'w').close()
	htmlstring = generate_html ( content )
	htmlfile = open( htmlfilename , 'w' )
	htmlfile.truncate()
	htmlfile.write( htmlstring )
	htmlfile.close()

#--------------
# Function for saving the disk usage to a file. Called by HTML-Form
#--------------
def get_usage(drive):

	try:
		file_mod_time = modification_date(htmlfilename)
	except OSError:
		content = prepare_line(drive)
		generate_html_into_file(content)
		file_mod_time = modification_date(htmlfilename)

	now = datetime.datetime.today()
	max_delay = datetime.timedelta(0,delay)
	age = now - file_mod_time
	
	#Add delay.
	if age < max_delay:
		print "CRITICAL: {} modified {} minutes ago. Threshold set to {} minutes. Cannot update.".format(htmlfilename, age.seconds/60, max_delay.seconds/60)
	else:
		print "OK. File last modified {} minutes ago. Updating now...".format(age.seconds/60)
		content = prepare_line(drive)
		generate_html_into_file(content)

#--------------
# Function for returning the amount of free space as an Integer
#--------------
def FreeSpace(drive):
	""" Return the FreeSape of a shared drive in bytes"""
	try:
		usage = disk_usage(drive)
		floatpercent = float(usage.used) / float(usage.total)
		percent = int(100*floatpercent)
		return percent
	except:
		return 0


#--------------
# Function which formats the about of freespace into a nice readable format
#--------------
def prepare_line (drive):
	data = str(FreeSpace(drive))
	# Trying to make it look like this:
	#<div class='progress'>
	#  <div class='progress-bar' role='progressbar' aria-valuenow='15' aria-valuemin='0' aria-valuemax='100' style='width: 15%'>
	#    <span class='sr-only'>15% Full</span>
	#  </div>
	#</div>
	content = "<div class='progress'><div class='progress-bar' role='progressbar' aria-valuenow='" + data + "' aria-valuemin='0' aria-valuemax='100' style='width: " + data + "%'><span class='sr-only'>" + data + "% Full</span></div></div>"
	return content

#--------------
#  Generating static HTML File
#--------------
if __name__ == "__main__":

	disk = "/opt/piratebox/share/Shared"

	if os.path.exists(htmlfilename) != True:
		content = prepare_line(disk)
		generate_html_into_file(content)
	else:
		get_usage(disk)

	print "Generated HTML-DiskUsage File."
