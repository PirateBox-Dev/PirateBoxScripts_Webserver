#!/usr/bin/perl -wT

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

my $query = new CGI;

print $query->header ( );
print "Sorry, no Board is installed";

1;
