#!/usr/bin/perl -w
#
# Make sure the VT102 module can handle ANSI colour, underline, bold, etc.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 07-colour.t,v 1.3 2001/05/21 22:11:25 ivarch Exp $

require Term::VT102;

my @tests = (
#                (F,B,b,f,s,u,F,r)
  [ 7, 4, "\e[m0\e[1m1\e[2m2\e[4m3\e[5m4\e[7m5\e[m6\r\n",
    "0123456", [ [7,0,0,0,0,0,0,0],
                 [7,0,1,0,0,0,0,0],
                 [7,0,0,1,0,0,0,0],
                 [7,0,0,1,0,1,0,0],
                 [7,0,0,1,0,1,1,0],
                 [7,0,0,1,0,1,1,1],
                 [7,0,0,0,0,0,0,0] ],
  ],
  [ 7, 4, "\e[41;35m0\e[1m1\e[2m2\e[4m3\e[5m4\e[7m5\e[m6\r\n",
    "0123456", [ [5,1,0,0,0,0,0,0],
                 [5,1,1,0,0,0,0,0],
                 [5,1,0,1,0,0,0,0],
                 [5,1,0,1,0,1,0,0],
                 [5,1,0,1,0,1,1,0],
                 [5,1,0,1,0,1,1,1],
                 [7,0,0,0,0,0,0,0] ],
  ],
  [ 8, 4, "\e[33;42m0\e[1m1\e[21m2\e[2m3\e[22m4\e[38m5\e[39m6\e[49m7\r\n",
    "01234567",[ [3,2,0,0,0,0,0,0],
                 [3,2,1,0,0,0,0,0],
                 [3,2,0,0,0,0,0,0],
                 [3,2,0,1,0,0,0,0],
                 [3,2,0,0,0,0,0,0],
                 [7,2,0,0,0,1,0,0],
                 [7,2,0,0,0,0,0,0],
                 [7,0,0,0,0,0,0,0] ],
  ],
);

$nt = scalar @tests;		# number of sub-tests

foreach $i (1 .. $nt) {
  my $testref = shift @tests;
  my ($cols, $rows, $text, @output) = @$testref;
  my ($ncols, $nrows, $row, $col, $line, $aline, $alineref, $galine, $passed);

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

  while ($#output > 0) {
    $line = shift @output;
    $alineref = shift @output;
    $aline = "";
    foreach (@$alineref) {
      $aline .= $vt->attr_pack (@$_);
    }
    $row ++;
    if ($vt->row_text ($row) ne $line) {
      $passed = 0;
      print STDERR "test $i: row $row incorrect, got '" .
                   show_text ($vt->row_text ($row)) . "', expected '" .
                   show_text ($line) . "'\n";
      next;
    }
    $galine = $vt->row_attr ($row);
    for ($col = 0; $col < $cols; $col ++) {
      if (substr ($aline, 2 * $col, 2) ne substr ($galine, 2 * $col, 2)) {
        $passed = 0;
        print STDERR "test $i: row $row col " . ($col + 1) .
                     " attributes incorrect, got '" .
                     show_attr ($vt, substr ($galine, 2 * $col, 2)) .
                     "', expected '" .
                     show_attr ($vt, substr ($aline, 2 * $col, 2)) . "'\n";
        next;
      }
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


sub show_attr {
  my ($vt, $attr) = @_;
  my ($fg,$bg,$bo,$fa,$st,$ul,$bl,$rv) = $vt->attr_unpack ($attr);
  my $str = "$fg-$bg";
  $str .= "b" if ($bo != 0);
  $str .= "f" if ($fa != 0);
  $str .= "s" if ($st != 0);
  $str .= "u" if ($ul != 0);
  $str .= "F" if ($bl != 0);
  $str .= "r" if ($rv != 0);
  return $str . "-" . sprintf ("%04X", unpack ('S', $attr));
}

# EOF
