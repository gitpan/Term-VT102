#!/usr/bin/perl -w
#
# Make sure the VT102 module can handle scrolling up and down.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 05-scrolling.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $

require Term::VT102;
require 't/testbase';

my $fill = "0123456789\r\n" .
           "1234567890\r\n" .
           "2345678901\r\n" .
           "3456789012\e[H";
my $fill2 = "0123456789\r\n" .
            "1234567890\r\n" .
            "2345678901\r\n" .
            "3456789012\e[2;3r\e[2H";

run_tests ([(
  [ 10, 4, $fill . "",				# 1: nothing
    "0123456789",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill . "\e[4H\ntest",		# 2: LF
    "1234567890",
    "2345678901",
    "3456789012",
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\eMtest",			# 3: RI
    "test" . ("\0" x 6),
    "0123456789",
    "1234567890",
    "2345678901",
  ],
  [ 10, 4, $fill . "\e[4H\eDtest",		# 4: IND
    "1234567890",
    "2345678901",
    "3456789012",
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\e[4H\eEtest",		# 5: NEL
    "1234567890",
    "2345678901",
    "3456789012",
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\e[2Atest",			# 6: CUU
    "test" . ("\0" x 6),
    "\0" x 10,
    "0123456789",
    "1234567890",
  ],
  [ 10, 4, $fill . "\e[8Atest",			# 7: CUU
    "test" . ("\0" x 6),
    "\0" x 10,
    "\0" x 10,
    "\0" x 10,
  ],
  [ 10, 4, $fill . "\e[4H\e[2Btest",		# 8: CUD
    "2345678901",
    "3456789012",
    "\0" x 10,
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\e[4H\e[2Etest",		# 9: CNL
    "2345678901",
    "3456789012",
    "\0" x 10,
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\e[4H\e[9Etest",		# 10: CNL
    "\0" x 10,
    "\0" x 10,
    "\0" x 10,
    "test" . ("\0" x 6),
  ],
  [ 10, 4, $fill . "\e[2Ftest",			# 11: CPL
    "test" . ("\0" x 6),
    "\0" x 10,
    "0123456789",
    "1234567890",
  ],
  [ 10, 4, $fill2 . "",				# 12: nothing (with DECSTBM)
    "0123456789",
    "1234567890",
    "2345678901",
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[3H\e[Etest",		# 13: DECSTBM CNL
    "0123456789",
    "2345678901",
    "test" . ("\0" x 6),
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[Ftest",			# 14: DECSTBM CPL
    "0123456789",
    "test" . ("\0" x 6),
    "1234567890",
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[3H\e[2Etest",		# 15: DECSTBM CNL 2
    "0123456789",
    "\0" x 10,
    "test" . ("\0" x 6),
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[2Ftest",		# 16: DECSTBM CPL 2
    "0123456789",
    "test" . ("\0" x 6),
    "\0" x 10,
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[3H\e[4Etest",		# 17: DECSTBM CNL 4
    "0123456789",
    "\0" x 10,
    "test" . ("\0" x 6),
    "3456789012",
  ],
  [ 10, 4, $fill2 . "\e[4Ftest",		# 18: DECSTBM CPL 4
    "0123456789",
    "test" . ("\0" x 6),
    "\0" x 10,
    "3456789012",
  ],
)]);

# EOF $Id: 05-scrolling.t,v 1.2 2002/04/16 23:43:59 ivarch Exp $
