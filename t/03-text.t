#!/usr/bin/perl -w
#
# Make sure the VT102 module can process basic text OK.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 03-text.t,v 1.4 2001/05/21 22:11:25 ivarch Exp $

require Term::VT102;

my @tests = (
  [ 10, 5, "line 1\r\n  line 2\r\n  line 3\r\nline 4",
    "line 1" . ("\0" x 4),
    "  line 2" . ("\0" x 2),
    "  line 3" . ("\0" x 2),
    "line 4" . ("\0" x 4),
  ],
  [ 80, 25, " line 1 \n    line 2\n    line 3\n line 4 ",
    " line 1 " . ("\0" x 72),
    ("\0" x 8) . "    line 2" . ("\0" x 62),
    ("\0" x 18) . "    line 3" . ("\0" x 52),
    ("\0" x 28) . " line 4 " . ("\0" x 44),
  ],
  [ 40, 5, "line 1\ttab 1\r\n  line 2\ttab 2\ttab 3\r\n  line 3\r\nline 4",
    "line 1  tab 1" . ("\0" x 27),
    "  line 2        tab 2   tab 3" . ("\0" x 11),
    "  line 3" . ("\0" x 32),
    "line 4" . ("\0" x 34),
  ],
);

$nt = scalar @tests;		# number of sub-tests

foreach $i (1 .. $nt) {
  my $testref = shift @tests;
  my ($cols, $rows, $text, @output) = @$testref;
  my ($ncols, $nrows, $row, $line, $passed);

  print "$i..$nt\n";

  my $vt = Term::VT102->new ('cols' => $cols, 'rows' => $rows);

  ($ncols, $nrows) = $vt->size ();

  if (($cols != $ncols) or ($rows != $nrows)) {
    print "not ok $i\n";
    print STDERR "returned size: $ncols x $nrows, wanted $cols x $rows\n";
    next;
  }

  $vt->process ($text);

  $row = 0;
  $passed = 1;

  while ($line = shift @output) {
    $row ++;
    if ($vt->row_text ($row) ne $line) {
      $passed = 0;
      print STDERR "test $i: row $row incorrect, got '" .
                   show_text ($vt->row_text ($row)) . "', expected '" .
                   show_text ($line) . "'\n";
      next;
    }
  }

  if ($passed == 0) {
    print "not ok $i\n";
  } else {
    print "ok $i\n";
  }
}


sub show_text {
  my ($text) = @_;
  return "" if (not defined $text);
  $text =~ s/([^\040-\176])/sprintf ("\\%o", ord ($1))/ge;
  return $text;
}

# EOF
