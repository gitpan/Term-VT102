#!/usr/bin/perl -w
#
# Test DECSC and DECRC.
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: 11-decscrc.t,v 1.1 2002/11/27 22:36:41 ivarch Exp $

require Term::VT102;
require 't/testbase';

run_tests ([(
#              (F,B,b,f,s,u,F,r)
  [ 5, 3, "\e[41;33mtest\e7\e[2H\e[42;34mgrok\e7\e[m\e[3Hfoo\e82\e81",
    "test1", [ [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0],
               [3,1,0,0,0,0,0,0] ],
    "grok2", [ [4,2,0,0,0,0,0,0],
               [4,2,0,0,0,0,0,0],
               [4,2,0,0,0,0,0,0],
               [4,2,0,0,0,0,0,0],
               [4,2,0,0,0,0,0,0] ],
    "foo\0\0", [ [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0],
               [7,0,0,0,0,0,0,0] ],
  ],
)]);

# EOF $Id: 11-decscrc.t,v 1.1 2002/11/27 22:36:41 ivarch Exp $
