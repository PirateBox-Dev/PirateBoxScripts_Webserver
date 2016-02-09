#   PirateBox  Message  lib  (C)2012-2014
#      Matthias Strubel

import string
import socket
import base64
import sys


class message:
    def __init__(self, name="generate"):
        if name == "generate":
            self.name = socket.gethostname()
        else:
            self.name = name

        self.type = "gc"
        self.decoded = ""

    def set(self, content=" "):
        base64content = base64.b64encode(content)
        self.decoded = "piratebox;" + self.type + ";01;" + self.name + ";" + \
                       base64content

    def get(self):
        # TODO    Split decoded part
        message_parts = string.split(self.decoded, ";")

        if message_parts[0] != "piratebox":
            return None

        b64_content_part = message_parts[4]

        content = base64.b64decode(b64_content_part)
        return content

    def get_sendername(self):
        return self.name

    def get_message(self):
        return self.decoded

    def set_message(self, decoded):
        self.decoded = decoded


class shoutbox_message(message):
    def __init__(self, name="generate"):
        message.__init__(self, name)
        self.type = "sb"
