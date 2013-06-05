#!/usr/bin/python

# Modificated ShoutBox Library
#   enables further modifications for the ShoutBox
#   Run without to generate htmlfile
#   Run the following to enter a new line from command line
#     psogen.py input Anonymous default "Text" 

import os, datetime, re 

import messages, broadcast

datafilename = os.environ["SHOUTBOX_CHATFILE"]
htmlfilename = os.environ["SHOUTBOX_GEN_HTMLFILE"]

try:
     raw_dest =  os.environ["SHOUTBOX_BROADCAST_DESTINATIONS"]
     finished_dest = re.sub ( '#' , '"' , raw_dest ) 
     broadcast_destination = eval ( finished_dest ) 
except KeyError:
     broadcast_destination = False 


#--------------
#  Generates Shoutbox-HTML-Frame  ... 
#           Imports:
#               content    -   String  containing preformatted data
#--------------
def generate_html(content):
    htmlstring =   "<html><head><meta http-equiv='cache-control' content='no-cache'><meta name='GENERATOR' content='PyShoutOut'><title>Shout-Out Data</title><body>"  
    htmlstring +=  content 
    htmlstring +=  "</body></html>" 
    return htmlstring 

#--------------
#   Generates HTML Data based on given content  and write it to static html file
#          Imports: 
#               content    -   String  containing preformatted data
#--------------
def generate_html_into_file(content):
    htmlstring = generate_html ( content )

    htmlfile = open( htmlfilename , 'w' )
    htmlfile.write( htmlstring )
    htmlfile.close()

#--------------
# Generates HTML Data based on datafilename 's content 
#--------------
def generate_html_from_file():
    old =  read_data_file() 
    generate_html_into_file( old   )

#--------------
# Generates and Displays generated HTML
#--------------
def generate_html_to_display_from_file():    
    old =  read_data_file()
    htmlstring = generate_html ( old )
    print htmlstring 

#--------------
#  Reads Data file from datafilename given name
#--------------
def read_data_file():
    datafile = open(datafilename, 'r')
    old = datafile.read()
    datafile.close()
    return old

#--------------
# Function for saving new Shoubox-Content & Regenerate static HTML file -- usually called by HTML-Form
#--------------
def process_form( name , indata , color ):
    content = save_input(  name , indata , color ) 

    if broadcast_destination == False:
          generate_html_into_file ( content )


#--------------
# Acutally Saves SB-Content to datafile
#--------------
def save_input( name , indata , color ):

    content = prepare_line ( name, indata, color  )

    if broadcast_destination != False:
        return writeToNetwork( content , broadcast_destination )
    else:
        return writeToDisk ( content )

def writeToNetwork ( content , broadcast_destination ):
        message = messages.shoutbox_message()
	message.set(content)
        casting = broadcast.broadcast( )
	casting.setDestination(broadcast_destination)
	casting.set( message.get_message() )
	casting.send()
	return None

def writeToDisk ( content ):
        old = read_data_file()
        finalcontent = content  + old 
        datafile = open(datafilename, 'r+')
        datafile.write(finalcontent)
        #datafile.truncate(0)
        datafile.close()
	return finalcontent 


def prepare_line ( name, indata, color  ):
    datapass = re.sub("<", "&lt;", indata)
    data = re.sub(">", "&gt;", datapass)
    curdate = datetime.datetime.now()
    # Trying to make it look like this: 
    # <div class="comment">
    #     <date>00:00:00</date> <name>Nickname:</name> <data class="def">Lorem ipsum dolor sit amet</data>
    # </div>
    content = "<div class='comment'><date>" + curdate.strftime("%H:%M:%S") + "</date> <name>" + name + ":</name> <data class='" + color + "'>" + data + "</data></div>\n" 
    return content

#--------------
#  Testing or Generating static HTML File
#--------------
if __name__ == "__main__":
  import sys
  if sys.argv.count("input") >= 1 :
     save_input(  sys.argv[2] ,  sys.argv[3] ,  sys.argv[4] )
     generate_html_to_display_from_file()
     print "Entered Text."
  
  generate_html_from_file ()
  print "Generated HTML-Shoutbox File."



