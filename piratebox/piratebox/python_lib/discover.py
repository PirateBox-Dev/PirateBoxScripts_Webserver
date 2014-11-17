#   PirateBox  Message broadcasting lib  (C)2012-2014
#      Matthias Strubel

import SocketServer
import socket
import sys
import os

import messages
from psogen import writeToDisk, generate_html_from_file


lastmsg = ""


class MyUDPHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        global lastmsg
        data = self.request[0].strip()
        socket = self.request[1]
        if data[:9] == "piratebox":
            if data[10:12] == "sb":
                if data != lastmsg:
                    msg = messages.shoutbox_message()
                    msg.set_message(data)
                    content = msg.get()
                    writeToDisk(content)
                    generate_html_from_file()
                    lastmsg = data
            else:
                print data[11:12]
                print data
        else:
            print "debug : not a piratebox message"


class UDPServer(SocketServer.UDPServer):
    def setIPv6(self, ipv6=1):
        if ipv6 == 0:
            self.disable_ipv6 = 1
        else:
            self.disable_ipv6 = 0

    def useIPv6(self):
        return True

        if self.disable_ipv6 == 1:
            return False
        else:
            return True

    if socket.has_ipv6:
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
                self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY,
                                       0)
        self.socket.bind(self.server_address)

if __name__ == "__main__":
    HOST, PORT = ("::", 12556)
    server = UDPServer((HOST, PORT), MyUDPHandler)
    server.setIPv6(0)
    server.serve_forever()
