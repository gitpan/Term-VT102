#!/usr/bin/perl -w
#
# Make sure the VT102 module's callbacks work.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 09-callback.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $

require Term::VT102;

my $nt = 1;
my $i = 1;

print "$i..$nt\n";

# TODO: write some callback tests

print "ok $i\n";
$i ++;

# EOF $Id: 09-callback.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $
