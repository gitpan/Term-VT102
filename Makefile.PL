#!/usr/bin/perl -w
#
# Call MakeMaker and get it to build the Makefile.
#
# $Id: Makefile.PL,v 1.2 2002/08/02 23:11:45 ivarch Exp $

use lib "lib";
use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
	'NAME'         => 'Term::VT102',
	'VERSION_FROM' => 'VT102.pm',
	'ABSTRACT'     => 'emulate a DEC VT102 terminal',
	'AUTHOR'       => 'Andrew Wood <andrew.wood@ivarch.com>'
);

# EOF
