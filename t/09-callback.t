#!/usr/bin/perl -w
#
# Make sure the VT102 module's callbacks work.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 09-callback.t,v 1.2 2001/05/21 22:28:24 ivarch Exp $

require Term::VT102;

my $nt = 1;
my $i = 1;

print "$i..$nt\n";

# TODO: write some callback tests

print "ok $i\n";
$i ++;

# EOF
