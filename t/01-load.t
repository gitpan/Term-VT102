#!/usr/bin/perl -w
#
# Make sure the VT102 module loads OK and can return its version number.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 01-load.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $

BEGIN {
	print "1..1\n";
}

require Term::VT102;

my $vt = Term::VT102->new ('cols' => 80, 'rows' => 25);

print "Version: " . $vt->version () . "\n";

print "ok 1\n";

# EOF $Id: 01-load.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $
