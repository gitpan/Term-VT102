#!/usr/bin/perl -w
#
# Call MakeMaker and get it to build the Makefile.
#
# $Id: Makefile.PL,v 1.2 2001/05/20 16:58:20 ivarch Exp $

use lib "lib";
use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
  'NAME'	 => 'Term::VT102',
  'VERSION_FROM' => 'lib/Term/VT102.pm',
  'ABSTRACT'     => 'emulate a DEC VT102 terminal',
  'AUTHOR'       => 'Andrew Wood <andrew.wood@ivarch.com>'
);

# EOF
