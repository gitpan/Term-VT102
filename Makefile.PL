#!/usr/bin/perl -w
#
# Call MakeMaker and get it to build the Makefile.
#
# $Id: Makefile.PL,v 1.1.1.1 2001/11/04 18:50:29 ivarch Exp $

use lib "lib";
use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
  'NAME'	 => 'Term::VT102',
  'VERSION_FROM' => 'VT102.pm',
  'ABSTRACT'     => 'emulate a DEC VT102 terminal',
  'AUTHOR'       => 'Andrew Wood <andrew.wood@ivarch.com>'
);

# EOF
