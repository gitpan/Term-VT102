#!/usr/bin/perl -w
#
# Make sure the VT102 module's callbacks work.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 09-callback.t,v 1.3 2002/08/04 20:18:23 ivarch Exp $

require Term::VT102;

my $nt = 2;
my $i = 1;
my $testvar = 0;

print "$i..$nt\n";

my $vt = Term::VT102->new ('cols' => 80, 'rows' => 25);

$vt->callback_call ('ROWCHANGE', 0, 0);

print "ok $i\n";
$i ++;

$vt->callback_set ('ROWCHANGE', \&testcallback, 123);
$vt->callback_call ('ROWCHANGE', 0, 0);
if ($testvar != 123) {
	print "not ok $i\n";
} else {
	print "ok $i\n";
}
$i ++;

sub testcallback {
	my ($vtobj, $callname, $arg1, $arg2, $privdata) = @_;
	$testvar = $privdata;
}

# EOF $Id: 09-callback.t,v 1.3 2002/08/04 20:18:23 ivarch Exp $
