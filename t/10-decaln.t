#!/usr/bin/perl -w
#
# Test DECALN.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 10-decaln.t,v 1.1 2002/08/02 23:33:58 ivarch Exp $

require Term::VT102;
require 't/testbase';

run_tests ([(
#              (F,B,b,f,s,u,F,r)
  [ 5, 3, "b\e[41;33mlah\nblah\r\nblah\e#8test",
    "testE", [ [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0] ],
    "EEEEE", [ [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0] ],
    "EEEEE", [ [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0] ],
  ],
)]);

# EOF $Id: 10-decaln.t,v 1.1 2002/08/02 23:33:58 ivarch Exp $
