#!/usr/bin/python

# Modificated ShoutBox Library
#   enables further modifications for the ShoutBox
#   Run without to generate htmlfile
#   Run the following to enter a new line from command line
#     psogen.py input Anonymous default "Text" 

import os, datetime, re 

datafilename = "data.pso"
htmlfilename = "../chat_content.html"

def generate_html(content):
    css = open("style.css", 'r')
    stl =  css.read()
    css.close()

    htmlfile = open( htmlfilename , 'w' )
    htmlfile.write( "<html><head><meta name='GENERATOR' content='PyShoutOut'><title>Shout-Out Data</title><style type='text/css'>" )
    htmlfile.write( "<style>" + stl   + "</style></head><body>"  )
    htmlfile.write( content )
    htmlfile.write( "</body></html>" )
    htmlfile.close()

def generate_html_from_file():
    old =  read_data_file() 
    generate_html( old   )

def read_data_file():
    datafile = open(datafilename, 'r')
    old = datafile.read()
    datafile.close()
    return old

def process_form( name , indata , color ):
    old = read_data_file()
    datapass = re.sub("<", "&lt;", indata)
    data = re.sub(">", "&gt;", datapass)
    
    curdate = datetime.datetime.now()

    finalcontent = "<date>" + curdate.strftime("%H:%M:%S") + "</date>&nbsp;&nbsp;<name>" + name + ":</name>&nbsp;&nbsp;&nbsp;<data class='" + color + "'>" + data + "</data><br>\n" + old 
    datafile = open(datafilename, 'r+')
    datafile.write(finalcontent)
    datafile.truncate(0)
    datafile.close()
    generate_html(finalcontent)


if __name__ == "__main__":
  import sys
  if sys.argv.count("input") >= 1 :
     process_form(  sys.argv[2] ,  sys.argv[3] ,  sys.argv[4] )
     print "Entered Text."
     
  generate_html_from_file()
  print "Generated HTML File."

