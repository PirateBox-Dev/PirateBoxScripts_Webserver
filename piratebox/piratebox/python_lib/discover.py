# Forban - a simple link-local opportunistic p2p free software
#
# For more information : http://www.foo.be/forban/
#
# Copyright (C) 2009-2010 Alexandre Dulaunoy - http://www.foo.be/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SocketServer
import socket
import sys
import os

import messages
from psogen import writeToDisk

global lastmsg
lastmsg = ""

class MyUDPHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        global lastmsg
        data = self.request[0].strip()
        socket = self.request[1]
        if data[:9] == "piratebox":
            if data[10:12] == "sb":
	       if data != lastmsg :
   	   	    msg = messages.shoutbox_message()
		    msg.set_message(data)
		    content = msg.get()
	            writeToDisk(content)
		    lastmsg = data
	    else:
	       print data[11:12]
	       print data
        else:
            print "debug : not a piratebox message"

class UDPServer(SocketServer.UDPServer):
    
    def setIPv6 (self, ipv6 = 1 ):
        if  ipv6 == 0 :
            self.disable_ipv6 = 1
        else:
            self.disable_ipv6 = 0

    def useIPv6 (self ):
        return True

        if self.disable_ipv6 == 1 :
            return False
        else:
            return True


    if socket.has_ipv6 :
        try:
            socktest = socket.socket(socket.AF_INET6)
            socktest.close()
            address_family = socket.AF_INET6
        except:
            address_family = socket.AF_INET

    def server_bind(self):

        if self.useIPv6():

             self.v6success = True
             try:
                 socktest = socket.socket(socket.AF_INET6)
                 socktest.close()
             except:
                 self.v6success = False

             if socket.has_ipv6 and self.v6success:
                 address_family = socket.AF_INET6

             #allowing to work in dual-stack when IPv6 is used
             if socket.has_ipv6 and self.v6success:
                 self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
          
        self.socket.bind(self.server_address)

if __name__ == "__main__":
   HOST, PORT = ("::",12556)
   server = UDPServer((HOST, PORT), MyUDPHandler)
   server.setIPv6(0)
   server.serve_forever()

