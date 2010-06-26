#!/usr/bin/perl
#
use strict;
use warnings;

use lib 'lib';
use TAP::Spec::Parser;
use Data::Dumper;

print Dumper(TAP::Spec::Parser->parse_from_handle(\*ARGV));

