#   PirateBox send Message lib  (C)2012-2014
#    modified by Matthias Strubel
#
#  Original Version by
#
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


import socket
import string
import time
import datetime
try:
    from hashlib import sha1
except ImportError:
    from sha import sha as sha1
import re
import sys


flogger = None
debug = 0


class broadcast:
    def __init__(self, name="notset", uuid=None, port="12556", timestamp=None,
                 auth=None, destination=["ff02::1", "255.255.255.255", ]):
        self.name = name
        self.uuid = uuid
        self.port = port
        self.count = 0
        self.destination = destination
        self.ipv6_disabled = 0

    def disableIpv6(self):
        self.ipv6_disabled = 1
        self.destination = ["255.255.255.255", ]

    def setDestination(self, destination=["ff02::1", "255.255.255.255", ]):
        self.destination = destination

    def set(self, content):
        self.payload = content

    def get(self):
        return self.payload

    def __debugMessage(self, msg):
        if flogger is not None:
            flogger.debug(msg)
        elif debug == 1:
            print msg

    def __errorMessage(self, msg):
        if flogger is not None:
            flogger.error(msg)
        elif debug == 1:
            print msg

    def send(self):
        for destination in self.destination:
            if socket.has_ipv6 and re.search(":", destination) and not \
                    self.ipv6_disabled == 1:

                self.__debugMessage("working in ipv6 part on destination " +
                                    destination)

                # Even if Python is compiled with IPv6, it doesn't mean that
                # the os is supporting IPv6. (like the Nokia N900)
                try:
                    sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM,
                                         socket.IPPROTO_UDP)
                    # Required on some version of MacOS X while sending IPv6
                    # UDP datagram
                    sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
                except:
                    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM,
                                         socket.IPPROTO_UDP)

            else:
                self.__debugMessage("open ipv4 socket on destination " +
                                    destination)
                sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM,
                                     socket.IPPROTO_UDP)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

            try:
                sock.sendto(self.payload, (destination, int(self.port)))
            except socket.error, msg:
                self.__errorMessage("Error sending to " + destination + " : " +
                                    msg.strerror)
                continue
        sock.close()


def managetest():
    msg = broadcast()
    msg.set("Test")
    print msg.get()
    msg.send()

if __name__ == "__main__":
    managetest()
