#!/usr/bin/perl -w
#
# Make sure the VT102 module can handle line and character insertion and
# deletion, and line/screen clearing.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 06-insdel.t,v 1.5 2001/05/21 22:11:25 ivarch Exp $

require Term::VT102;

my $fill = "0123456789\r\n" .
           "1234567890\r\n" .
           "2345678901\r\n" .
           "3456789012\e[H";

my @tests = (
  [ 10, 4, $fill . "",				# 1: nothing
    "0123456789",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[P",			# 2: DCH 1
    "123456789\0",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;8H\e[2P",		# 3: DCH 2
    "0123456789",
    "12345670\0\0",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[3;7H\e[9P",		# 4: DCH 9
    "0123456789",
    "1234567890",
    "234567\0\0\0\0",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[X",			# 5: ECH 1
    "\0" . "123456789",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;8H\e[2X",		# 6: ECH 2
    "0123456789",
    "1234567\0\0" . "0",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[3;7H\e[9X",		# 7: ECH 9
    "0123456789",
    "1234567890",
    "234567\0\0\0\0",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[@",			# 8: ICH 1
    "\0" . "012345678",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;8H\e[2@",		# 9: ICH 2
    "0123456789",
    "1234567\0\0" . "8",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[3;7H\e[9@",		# 10: ICH 9
    "0123456789",
    "1234567890",
    "234567\0\0\0\0",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[J",		# 11: ED 0
    "0123456789",
    "123" . ("\0" x 7),
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[2;4H\e[1J",		# 12: ED 1
    ("\0" x 10),
    ("\0" x 4) . "567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[2J",		# 13: ED 2
    ("\0" x 10),
    ("\0" x 10),
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[2;4H\e[K",		# 14: EL 0
    "0123456789",
    "123" . ("\0" x 7),
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[1K",		# 15: EL 1
    "0123456789",
    ("\0" x 4) . "567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[2K",		# 16: EL 2
    "0123456789",
    ("\0" x 10),
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[LAbC",		# 17: IL 1
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    "1234567890",
    "2345678901",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[2LAbC",		# 18: IL 2
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    "1234567890",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[9LAbC",		# 19: IL 3
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[1;1H\e[2LAbC",		# 20: IL 4
    "AbC" . ("\0" x 7),
    ("\0" x 10),
    "0123456789",
    "1234567890",
  ],
  [ 10, 4, $fill . "\e[2;4H\e[MAbC",		# 21: DL 1
    "0123456789",
    "234AbC8901",
    "3456789012",
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[2;4H\e[2MAbC",		# 22: DL 2
    "0123456789",
    "345AbC9012",
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[2;4H\e[9MAbC",		# 23: DL 3
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[1;1H\e[2MAbC",		# 24: DL 4
    "AbC5678901",
    "3456789012",
    ("\0" x 10),
    ("\0" x 10),
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[LAbC",	# 25: DECSTBM IL 1
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    "1234567890",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[2LAbC",	# 26: DECSTBM IL 2
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[9LAbC",	# 27: DECSTBM IL 3
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[1;1H\e[2LAbC",	# 28: DECSTBM IL 4
    "AbC" . ("\0" x 7),
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[MAbC",	# 29: DECSTBM DL 1
    "0123456789",
    "234AbC8901",
    ("\0" x 10),
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[2MAbC",	# 30: DECSTBM DL 2
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[2;4H\e[9MAbC",	# 31: DECSTBM DL 3
    "0123456789",
    ("\0" x 3) . "AbC" . ("\0" x 4),
    ("\0" x 10),
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[2;3r\e[1;1H\e[2MAbC",	# 32: DECSTBM DL 4
    "AbC" . ("\0" x 7),
    "1234567890",
    "2345678901",
    "3456789012",
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
