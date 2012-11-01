
import string
import socket

import base64

class message:
     
     def __init__(self, name="generate"  ):
         if name == "generate":
               self.name=sys.gethostname()
	 else:
	       self.name=name

	 self.type="generic"
	 self.decoded=""

     def set ( self, content=" " ):
         base64content = base64.b64encode (  self.content ) 
         self.decoded="piratebox;"+ self.type + ";01; " + self.name + ";" + base64content 
         
     def get ( self ):
         
	 # TODO    Split decoded part

         content = base64.b64decode ( b64_content_part ) 
         return content 

     def get_sendername (self):
         return self.name=name

     def get_message ( self ):
         return self.decoded

     def set_message ( self , decoded):
         self.decoded = decoded


