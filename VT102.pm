# Term::VT102 - module for VT102 emulation in Perl
#
# Copyright (C) Andrew Wood <andrew.wood@ivarch.com>
# NO WARRANTY - see COPYING.
#
# $Id: VT102.pm,v 1.5 2002/08/04 20:18:23 ivarch Exp $

package Term::VT102;

use strict;

BEGIN {
	use Exporter ();
	use vars qw($VERSION @ISA);

	$VERSION = '0.75';

	@ISA = qw(Exporter);
}


# Constructor function.
#
sub new {
	my ($proto, %init) = @_;
	my $class = ref ($proto) || $proto;
	my $self = {};

	$self->{'_ctlseq'} = { (  # control characters
	  "\000" => 'NUL',            # ignored
	  "\005" => 'ENQ',            # trigger answerback message
	  "\007" => 'BEL',            # beep
	  "\010" => 'BS',             # backspace one column
	  "\011" => 'HT',             # horizontal tab to next tab stop
	  "\012" => 'LF',             # line feed
	  "\013" => 'VT',             # line feed
	  "\014" => 'FF',             # line feed
	  "\015" => 'CR',             # carriage return
	  "\016" => 'SO',             # activate G1 character set & newline
	  "\017" => 'SI',             # activate G0 character set
	  "\021" => 'XON',            # resume transmission
	  "\023" => 'XOFF',           # stop transmission, ignore characters
	  "\030" => 'CAN',            # interrupt escape sequence
	  "\032" => 'SUB',            # interrupt escape sequence
	  "\033" => 'ESC',            # start escape sequence
	  "\177" => 'DEL',            # ignored
	  "\233" => 'CSI'             # equivalent to ESC [
	) };

	$self->{'_escseq'} = { (  # escape sequences
	   'c' => 'RIS',              # reset
	   'D' => 'IND',              # line feed
	   'E' => 'NEL',              # newline
	   'H' => 'HTS',              # set tab stop at current column
	   'M' => 'RI',               # reverse line feed
	   'Z' => 'DECID',            # DEC private ID; return ESC [ ? 6 c (VT102)
	   '7' => 'DECSC',            # save state (position, charset, attributes)
	   '8' => 'DECRC',            # restore most recently saved state
	   '[' => 'CSI',              # control sequence introducer
	  '[[' => 'IGN',              # ignored control sequence
	  '%@' => 'CSDFL',            # select default charset (ISO646/8859-1)
	  '%G' => 'CSUTF8',           # select UTF-8
	  '%8' => 'CSUTF8',           # select UTF-8 (obsolete)
	  '#8' => 'DECALN',           # DEC alignment test - fill screen with E's
	  '(8' => 'G0DFL',            # G0 charset = default mapping (ISO8859-1)
	  '(0' => 'G0GFX',            # G0 charset = VT100 graphics mapping
	  '(U' => 'G0ROM',            # G0 charset = null mapping (straight to ROM)
	  '(K' => 'G0USR',            # G0 charset = user defined mapping
	  ')8' => 'G1DFL',            # G1 charset = default mapping (ISO8859-1)
	  ')0' => 'G1GFX',            # G1 charset = VT100 graphics mapping
	  ')U' => 'G1ROM',            # G1 charset = null mapping (straight to ROM)
	  ')K' => 'G1USR',            # G1 charset = user defined mapping
	  '*8' => 'G2DFL',            # G2 charset = default mapping (ISO8859-1)
	  '*0' => 'G2GFX',            # G2 charset = VT100 graphics mapping
	  '*U' => 'G2ROM',            # G2 charset = null mapping (straight to ROM)
	  '*K' => 'G2USR',            # G2 charset = user defined mapping
	  '+8' => 'G3DFL',            # G3 charset = default mapping (ISO8859-1)
	  '+0' => 'G3GFX',            # G3 charset = VT100 graphics mapping
	  '+U' => 'G3ROM',            # G3 charset = null mapping (straight to ROM)
	  '+K' => 'G3USR',            # G3 charset = user defined mapping
	   '>' => 'DECPNM',           # set numeric keypad mode
	   '=' => 'DECPAM',           # set application keypad mode
	   'N' => 'SS2',              # select G2 charset for next char only
	   'O' => 'SS3',              # select G3 charset for next char only
	   'P' => 'DCS',              # device control string (ended by ST)
	   'X' => 'SOS',              # start of string
	   '^' => 'PM',               # privacy message (ended by ST)
	  "\\" => 'ST',               # string terminator
	   'n' => 'LS2',              # invoke G2 charset
	   'o' => 'LS3',              # invoke G3 charset
	   '|' => 'LS3R',             # invoke G3 charset as GR
	   '}' => 'LS2R',             # invoke G2 charset as GR
	   '~' => 'LS1R',             # invoke G1 charset as GR
	   ']' => 'OSC'               # operating system command
	) };

	$self->{'_csiseq'} = { (  # ECMA-48 CSI sequences
	  '[' => 'IGN',               # ignored control sequence
	  '@' => 'ICH',               # insert blank characters
	  'A' => 'CUU',               # move cursor up
	  'B' => 'CUD',               # move cursor down
	  'C' => 'CUF',               # move cursor right
	  'D' => 'CUB',               # move cursor left
	  'E' => 'CNL',               # move cursor down and to column 1
	  'F' => 'CPL',               # move cursor up and to column 1
	  'G' => 'CHA',               # move cursor to column in current row
	  'H' => 'CUP',               # move cursor to row, column
	  'J' => 'ED',                # erase display
	  'K' => 'EL',                # erase line
	  'L' => 'IL',                # insert blank lines
	  'M' => 'DL',                # delete lines
	  'P' => 'DCH',               # delete characters on current line
	  'X' => 'ECH',               # erase characters on current line
	  'a' => 'HPR',               # move cursor right
	  'c' => 'DA',                # return ESC [ ? 6 c (VT102)
	  'd' => 'VPA',               # move to row (current column)
	  'e' => 'VPR',               # move cursor down
	  'f' => 'HVP',               # move cursor to row, column
	  'g' => 'TBC',               # clear tab stop (CSI 3 g = clear all stops)
	  'h' => 'SM',                # set mode
	  'l' => 'RM',                # reset mode
	  'm' => 'SGR',               # set graphic rendition
	  'n' => 'DSR',               # device status report
	  'q' => 'DECLL',             # set keyboard LEDs
	  'r' => 'DECSTBM',           # set scrolling region to (top, bottom) rows
	  's' => 'CUPSV',             # save cursor position
	  'u' => 'CUPRS',             # restore cursor position
	  '`' => 'HPA'                # move cursor to column in current row
	) };

	$self->{'_funcs'} = { (     # supported character sequences
	      'BEL' => \&_code_BEL,   # beep
	       'BS' => \&_code_BS,    # backspace one column
	      'CAN' => \&_code_CAN,   # interrupt escape sequence
	      'CHA' => \&_code_CHA,   # move cursor to column in current row
	      'CNL' => \&_code_CNL,   # move cursor down and to column 1
	      'CPL' => \&_code_CPL,   # move cursor up and to column 1
	       'CR' => \&_code_CR,    # carriage return
	    'CSDFL' => undef,         # select default charset (ISO646/8859-1)
	      'CSI' => \&_code_CSI,   # equivalent to ESC [
	   'CSUTF8' => undef,         # select UTF-8 (obsolete)
	      'CUB' => \&_code_CUB,   # move cursor left
	      'CUD' => \&_code_CUD,   # move cursor down
	      'CUF' => \&_code_CUF,   # move cursor right
	    'CUPRS' => undef,         # restore cursor position
	    'CUPSV' => undef,         # save cursor position
	      'CUP' => \&_code_CUP,   # move cursor to row, column
	      'CUU' => \&_code_CUU,   # move cursor up
	       'DA' => \&_code_DA,    # return ESC [ ? 6 c (VT102)
	      'DCH' => \&_code_DCH,   # delete characters on current line
	      'DCS' => undef,         # device control string (ended by ST)
	   'DECALN' => \&_code_DECALN,# DEC alignment test - fill screen with E's
	    'DECID' => \&_code_DA,    # DEC private ID; return ESC [ ? 6 c (VT102)
	    'DECLL' => undef,         # set keyboard LEDs
	   'DECPAM' => undef,         # set application keypad mode
	   'DECPNM' => undef,         # set numeric keypad mode
	    'DECRC' => undef,         # restore most recently saved state
	    'DECSC' => undef,         # save state (position, charset, attributes)
	  'DECSTBM' => \&_code_DECSTBM, # set scrolling region
	      'DEL' => \&_code_IGN,   # ignored
	       'DL' => \&_code_DL,    # delete lines
	      'DSR' => \&_code_DSR,   # device status report
	      'ECH' => \&_code_ECH,   # erase characters on current line
	       'ED' => \&_code_ED,    # erase display
	       'EL' => \&_code_EL,    # erase line
	      'ENQ' => undef,         # trigger answerback message
	      'ESC' => \&_code_ESC,   # start escape sequence
	       'FF' => \&_code_LF,    # line feed
	    'G0DFL' => undef,         # G0 charset = default mapping (ISO8859-1)
	    'G0GFX' => undef,         # G0 charset = VT100 graphics mapping
	    'G0ROM' => undef,         # G0 charset = null mapping (straight to ROM)
	    'G0USR' => undef,         # G0 charset = user defined mapping
	    'G1DFL' => undef,         # G1 charset = default mapping (ISO8859-1)
	    'G1GFX' => undef,         # G1 charset = VT100 graphics mapping
	    'G1ROM' => undef,         # G1 charset = null mapping (straight to ROM)
	    'G1USR' => undef,         # G1 charset = user defined mapping
	    'G2DFL' => undef,         # G2 charset = default mapping (ISO8859-1)
	    'G2GFX' => undef,         # G2 charset = VT100 graphics mapping
	    'G2ROM' => undef,         # G2 charset = null mapping (straight to ROM)
	    'G2USR' => undef,         # G2 charset = user defined mapping
	    'G3DFL' => undef,         # G3 charset = default mapping (ISO8859-1)
	    'G3GFX' => undef,         # G3 charset = VT100 graphics mapping
	    'G3ROM' => undef,         # G3 charset = null mapping (straight to ROM)
	    'G3USR' => undef,         # G3 charset = user defined mapping
	      'HPA' => \&_code_CHA,   # move cursor to column in current row
	      'HPR' => \&_code_CUF,   # move cursor right
	      'HTS' => undef,         # set tab stop at current column
	       'HT' => \&_code_HT,    # horizontal tab to next tab stop
	      'HVP' => \&_code_CUP,   # move cursor to row, column
	      'ICH' => \&_code_ICH,   # insert blank characters
	      'IGN' => \&_code_IGN,   # ignored control sequence
	       'IL' => \&_code_IL,    # insert blank lines
	      'IND' => \&_code_LF,    # line feed
	       'LF' => \&_code_LF,    # line feed
	     'LS1R' => undef,         # invoke G1 charset as GR
	     'LS2R' => undef,         # invoke G2 charset as GR
	      'LS2' => undef,         # invoke G2 charset
	     'LS3R' => undef,         # invoke G3 charset as GR
	      'LS3' => undef,         # invoke G3 charset
	      'NEL' => \&_code_CUD,   # newline
	      'NUL' => \&_code_IGN,   # ignored
	      'OSC' => \&_code_OSC,   # operating system command
	       'PM' => undef,         # privacy message (ended by ST)
	      'RIS' => \&_code_RIS,   # reset
	       'RI' => \&_code_CUU,   # reverse line feed
	       'RM' => undef,         # reset mode
	      'SGR' => \&_code_SGR,   # set graphic rendition
	       'SI' => undef,         # activate G0 character set
	       'SM' => undef,         # set mode
	      'SOS' => undef,         # start of string
	       'SO' => undef,         # activate G1 character set & CR
	      'SS2' => undef,         # select G2 charset for next char only
	      'SS3' => undef,         # select G3 charset for next char only
	       'ST' => undef,         # string terminator
	      'SUB' => \&_code_CAN,   # interrupt escape sequence
	      'TBC' => undef,         # clear tab stop (CSI 3 g = clear all stops)
	      'VPA' => \&_code_VPA,   # move to row (current column)
	      'VPR' => \&_code_CUD,   # move cursor down
	       'VT' => \&_code_LF,    # line feed
	     'XOFF' => undef,         # stop transmission, ignore characters
	      'XON' => undef,         # resume transmission
	) };

	$self->{'_callbacks'} = { (   # available callbacks
	  'BELL'              => undef,   # bell character received
	  'CLEAR'             => undef,   # screen cleared
	  'OUTPUT'            => undef,   # data to be sent back to originator
	  'ROWCHANGE'         => undef,   # screen row changed
	  'SCROLL_DOWN'       => undef,   # text about to move up (par=top row)
	  'SCROLL_UP'         => undef,   # text about to move down (par=bott.)
	  'UNKNOWN'           => undef,   # unknown character / sequence
	  'XICONNAME'         => undef,   # xterm icon name changed
	  'XWINTITLE'         => undef    # xterm window title changed
	) };

	$self->{'_callbackarg'} = { () }; # stored arguments for callbacks

	$self->{'cols'} = 80;     # default: 80 columns
	$self->{'rows'} = 24;     # default: 24 rows

	$self->{'cols'} = $init{'cols'}
	  if ((defined $init{'cols'}) && ($init{'cols'} > 0));
	$self->{'rows'} = $init{'rows'}
	  if ((defined $init{'rows'}) && ($init{'rows'} > 0));

	bless ($self, $class);

	$self->reset ();

	return $self;
}


# Call a callback function with the given parameters.
#
sub callback_call {
	my ($self, $callback, $par1, $par2) = (@_);
	my ($func, $arg);

	$func = $self->{'_callbacks'}->{$callback};
	return if (not defined $func);

	$arg = $self->{'_callbackarg'}->{$callback};

	&{$func} ($self, $callback, $par1, $par2, $arg);
}


# Set a callback function.
#
sub callback_set {
	my ($self, $callback, $ref, $arg) = (@_);
	$self->{'_callbacks'}->{$callback} = $ref;
	$self->{'_callbackarg'}->{$callback} = $arg;
}


# Reset the terminal to "power-on" values.
#
sub reset {
	my $self = shift;
	my ($a, $b, $i);

	$self->{'x'} = 1;                     # default X position: 1
	$self->{'y'} = 1;                     # default Y position: 1

	$self->{'attr'} = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	$self->{'ti'} = '';                   # default: blank window title
	$self->{'ic'} = '';                   # default: blank icon title

	$self->{'srt'} = 1;                   # scrolling region top: row 1
	$self->{'srb'} = $self->{'rows'};     # scrolling region bottom

	$self->{'opts'} = {};                 # blank all options
	$self->{'opts'}->{'LINEWRAP'} = 0;    # line wrapping off
	$self->{'opts'}->{'LFTOCRLF'} = 0;    # don't map LF -> CRLF

	$self->{'scrt'} = [ () ];             # blank screen text
	$self->{'scra'} = [ () ];             # blank screen attributes

	$a = "\000" x $self->{'cols'};        # set text to NUL
	$b = $self->{'attr'} x $self->{'cols'}; # set attributes to default

	foreach $i (1 .. $self->{'rows'}) {
		($self->{'scrt'}->[$i], $self->{'scra'}->[$i]) = ($a, $b);
	}

	$self->{'_buf'} = undef;              # blank the esc-sequence buffer
	$self->{'_inesc'} = 0;                # not in any escape sequence
}


# Resize the terminal.
#
sub resize {
	my $self = shift;
	my $cols = shift;
	my $rows = shift;

	$self->callback_call ('CLEAR', 0, 0);

	$self->{'cols'} = $cols;
	$self->{'rows'} = $rows;

	$self->reset ();
}


# Return the package version.
#
sub version {
	return $VERSION;
}


# Return the current number of columns.
#
sub cols {
	my $self = shift;
	return $self->{'cols'};
}


# Return the current number of rows.
#
sub rows {
	my $self = shift;
	return $self->{'rows'};
}


# Return the current terminal size.
#
sub size {
	my $self = shift;
	return ( $self->{'cols'}, $self->{'rows'} );
}


# Return the current cursor X co-ordinate.
#
sub x {
	my $self = shift;
	return $self->{'x'};
}


# Return the current cursor Y co-ordinate.
#
sub y {
	my $self = shift;
	return $self->{'y'};
}


# Return the current xterm title text.
#
sub xtitle {
	my $self = shift;
	return $self->{'ti'};
}


# Return the current xterm icon text.
#
sub xicon {
	my $self = shift;
	return $self->{'ic'};
}


# Return the current terminal status.
#
sub status {
	my $self = shift;

	return (
	  $self->{'x'},               # cursor X position
	  $self->{'y'},               # cursor Y position
	  $self->{'attr'},            # packed attributes
	  $self->{'ti'},              # xterm title text
	  $self->{'ic'}               # xterm icon text
	);
}


# Return the unpacked version of a packed attribute.
#
sub attr_unpack {
	my $self = shift;
	my $data = shift;
	my ($num, $fg, $bg, $bo, $fa, $st, $ul, $bl, $rv);

	$num = unpack ('S', $data);

	($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv) = (
	  $num & 7,
	  ($num >> 4) & 7,
	  ($num >> 8) & 1,
	  ($num >> 9) & 1,
	  ($num >> 10) & 1,
	  ($num >> 11) & 1,
	  ($num >> 12) & 1,
	  ($num >> 13) & 1
	);

	return ($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv);
}


# Return the packed version of a set of attributes fg, bg, bo, fa, st, ul,
# bl, rv.
#
sub attr_pack {
	my $self = shift;
	my ($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv) = @_;
	my $num = 0;

	$num = ($fg & 7)
	  | (($bg & 7) << 4)
	  | ($bo << 8)
	  | ($fa << 9)
	  | ($st << 10)
	  | ($ul << 11)
	  | ($bl << 12)
	  | ($rv << 13);
	return pack ('S', $num);
}


# Process the given string, updating the terminal object and calling any
# necessary callbacks on the way.
#
sub process {
	my $self = shift;
	my ($string) = @_;

	return if (not defined $string);

	while (length $string > 0) {
		if (defined $self->{'_buf'}) {        # in escape sequence
			if ($string =~ s/^(.)//s) {
				$self->{'_buf'} .= $1;
				$self->_process_escseq ();
			}
		} else {                              # not in escape sequence
			if ($string =~
			    s/^([\040-\176\200-\232\234-\377]+)//s) {
				$self->_process_text ($1);
			} elsif ($string =~ s/^(.)//s) {
				$self->_process_ctl ($1);
			}
		}
	}
}


# Return the current value of the given option, or undef if it doesn't exist.
#
sub option_read {
	my $self = shift;
	my ($option) = @_;

	return undef if (not defined $option);
	return $self->{'opts'}->{$option};
}


# Set the value of the given option to the given value, returning the old
# value or undef if an invalid option was given.
#
sub option_set {
	my $self = shift;
	my ($option, $value) = @_;
	my $prev;

	return undef if (not defined $option);
	return undef if (not defined $value);
	return undef if (not defined $self->{'opts'}->{$option});

	$prev = $self->{'opts'}->{$option};
	$self->{'opts'}->{$option} = $value;
	return $prev;
}


# Return the attributes of the given row, or undef if out of range.
#
sub row_attr {
	my $self = shift;
	my ($row, $startcol, $endcol) = @_;
	my ($data);

	return undef if ($row < 1);
	return undef if ($row > $self->{'rows'});

	$data = $self->{'scra'}->[$row];

	if (defined $startcol && defined $endcol) {
		$data = substr (
		  $data,
		  ($startcol - 1) * 2,
		  (($endcol - $startcol) + 1) * 2
		);
	}

	return $data;
}


# Return the textual contents of the given row, or undef if out of range.
#
sub row_text {
	my $self = shift;
	my ($row, $startcol, $endcol) = @_;
	my $text;

	return undef if ($row < 1);
	return undef if ($row > $self->{'rows'});

	$text = $self->{'scrt'}->[$row];

	if (defined $startcol && defined $endcol) {
		$text = substr (
		  $text,
		  $startcol - 1,
		  ($endcol - $startcol) + 1
		);
	}

	return $text;
}


# Return the textual contents of the given row, or undef if out of range,
# with unused characters represented as a space instead of \0.
#
sub row_plaintext {
	my $self = shift;
	my ($row, $startcol, $endcol) = @_;
	my $text;

	return undef if ($row < 1);
	return undef if ($row > $self->{'rows'});

	$text = $self->{'scrt'}->[$row];
	$text =~ s/\0/ /g;

	if (defined $startcol && defined $endcol) {
		$text = substr (
		  $text,
		  $startcol - 1,
		  ($endcol - $startcol) + 1
		);
	}

	return $text;
}


# Process a string of plain text, with no special characters in it.
#
sub _process_text {
	my $self = shift;
	my ($text) = @_;
	my ($width, $segment);

	$width = ($self->{'cols'} + 1) - $self->{'x'};

	if ($self->{'opts'}->{'LINEWRAP'} == 0) {     # no line wrap - truncate
		return if ($width < 1);
		$text = substr ($text, 0, $width);
		substr (
		  $self->{'scrt'}->[$self->{'y'}], $self->{'x'} - 1,
		  length $text
		) = $text;
		substr (
		  $self->{'scra'}->[$self->{'y'}], 2 * ($self->{'x'} - 1),
		  2 * (length $text)
		) = $self->{'attr'} x (length $text);
		$self->{'x'} += length $text;
		$self->{'x'} = $self->{'cols'}
		  if ($self->{'x'} > $self->{'cols'});
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
		return;
	}

	while (length $text > 0) {                    # line wrapping enabled
		if ($width > 0) {
			$segment = substr ($text, 0, $width, '');
			substr (
			  $self->{'scrt'}->[$self->{'y'}], $self->{'x'} - 1,
			  length $segment
			) = $segment;
			substr (
			  $self->{'scra'}->[$self->{'y'}], 2*($self->{'x'}-1),
			  2 * (length $segment)
			) = $self->{'attr'} x (length $segment);
			$self->{'x'} += length $segment;
		}
		if ($self->{'x'} > $self->{'cols'}) {       # wrap to next line
			$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
			$self->{'x'} = 1;
			$self->_code_CUD (1);
		}
		$width = ($self->{'cols'} + 1) - $self->{'x'};
	}

	$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
}


# Process a control character.
#
sub _process_ctl {
	my $self = shift;
	my $ctl = shift;
	my ($name, $func);

	$name = $self->{'_ctlseq'}->{$ctl};
	return if (not defined $name);        # ignore unknown characters

	$func = $self->{'_funcs'}->{$name};
	if (not defined $func) {              # do nothing if unsupported
		$self->callback_call ('UNKNOWN', $name, $ctl);
	} else {                              # call handler function
		&{$func} ($self, $name);
	}
}


# Check the escape-sequence buffer, and process it if necessary.
#
sub _process_escseq {
	my $self = shift;
	my ($prefix, $suffix, $func, $name, $dat);
	my @params;

	return if (not defined $self->{'_buf'});
	return if (length $self->{'_buf'} < 1);

	if ($self->{'_inesc'} == 3) {                 # in OSC sequence
		if (
		  $self->{'_buf'} =~ /^0;([^\007]*)\007/
		) {                                          # icon & window
			$dat = $1;
			$self->callback_call ('XWINTITLE', $dat, 0);
			$self->callback_call ('XICONNAME', $dat, 0);
			$self->{'ic'} = $dat;
			$self->{'ti'} = $dat;
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		} elsif (
		  $self->{'_buf'} =~ /^1;([^\007]*)\007/
		) {                                          # set icon name
			$dat = $1;
			$self->callback_call ('XICONNAME', $dat, 0);
			$self->{'ic'} = $dat;
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		} elsif (
		  $self->{'_buf'} =~ /^2;([^\007]*)\007/
		) {                                          # set window title
			$dat = $1;
			$self->callback_call ('XWINTITLE', $dat, 0);
			$self->{'ti'} = $dat;
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		} elsif (length $self->{'_buf'} > 1024) {    # OSC too long
			$self->callback_call (
			  'UNKNOWN', 'OSC', "\033]" . $self->{'_buf'}
			);
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		}
	} elsif ($self->{'_inesc'} == 2) {            # in CSI sequence
		foreach $suffix (keys %{$self->{'_csiseq'}}) {
			next if (length $self->{'_buf'} < length $suffix);
			next if (
			  substr (
			    $self->{'_buf'},
			    (length $self->{'_buf'}) - (length $suffix),
			    length $suffix
			  ) ne $suffix
			);
			$self->{'_buf'} = substr (
			  $self->{'_buf'},
			  0,
			  (length $self->{'_buf'}) - (length $suffix)
			);
			$name = $self->{'_csiseq'}->{$suffix};
			$func = $self->{'_funcs'}->{$name};
			if (not defined $func) {        # unsupported sequence
				$self->callback_call (
				  'UNKNOWN',
				  $name,
				  "\033[" . $self->{'_buf'} . $suffix
				);
				$self->{'_buf'} = undef;
				$self->{'_inesc'} = 0;
				return;
			}
			@params = split (';', $self->{'_buf'});
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
			&{$func} ($self, @params);
			return;
		}
		if (
		  length $self->{'_buf'} > 64
		) {                            # abort CSI sequence if too long
			$self->callback_call (
			  'UNKNOWN', 'CSI', "\033[" . $self->{'_buf'}
			);
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		}
	} else {                                      # in ESC sequence
		foreach $prefix (
		  keys %{$self->{'_escseq'}}
		) {
			next if (
			  substr ($self->{'_buf'}, 0, length $prefix)
			  ne $prefix
			);
			$name = $self->{'_escseq'}->{$prefix};
			$func = $self->{'_funcs'}->{$name};
			if (not defined $func) {        # unsupported sequence
				$self->callback_call (
				  'UNKNOWN',
				  $name,
				  "\033" . $self->{'_buf'}
				);
				$self->{'_buf'} = undef;
				$self->{'_inesc'} = 0;
				return;
			}
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
			&{$func} ($self);
			return;
		}
		if (
		  length $self->{'_buf'} > 8
		) {                           # abort ESC sequence if too long
			$self->callback_call (
			  'UNKNOWN',
			  'ESC',
			  "\033" . $self->{'_buf'}
			);
			$self->{'_buf'} = undef;
			$self->{'_inesc'} = 0;
		}
	}
}


# Scroll the scrolling region up such that the text in the scrolling region
# moves down, by the given number of lines.
#
sub _scroll_up {
	my $self = shift;
	my $lines = shift;
	my ($attr, $a, $b, $i);

	return if ($lines < 1);

	$self->callback_call ('SCROLL_UP', $self->{'srb'}, $lines);

	for ($i = $self->{'srb'}; $i >= ($self->{'srt'} + $lines); $i --) {
		$self->{'scrt'}->[$i] = $self->{'scrt'}->[$i - $lines];
		$self->{'scra'}->[$i] = $self->{'scra'}->[$i - $lines];
	}

	$a = "\000" x $self->{'cols'};           # set text to NUL
	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);
	$b = $attr x $self->{'cols'};            # set attributes to default

	for (
	  $i = $self->{'srt'};
	  ($i <= $self->{'srb'}) && ($i < ($self->{'srt'} + $lines));
	  $i ++
	) {
		$self->{'scrt'}->[$i] = $a;      # blank new lines
		$self->{'scra'}->[$i] = $b;      # wipe attributes of new lines
	}
}


# Scroll the scrolling region down such that the text in the scrolling region
# moves up, by the given number of lines.
#
sub _scroll_down {
	my $self = shift;
	my $lines = shift;
	my ($a, $b, $i, $attr);

	$self->callback_call ('SCROLL_DOWN', $self->{'srt'}, $lines);

	for ($i = $self->{'srt'}; $i <= ($self->{'srb'} - $lines); $i ++) {
		$self->{'scrt'}->[$i] = $self->{'scrt'}->[$i + $lines];
		$self->{'scra'}->[$i] = $self->{'scra'}->[$i + $lines];
	}

	$a = "\000" x $self->{'cols'};           # set text to NUL
	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);
	$b = $attr x $self->{'cols'};            # set attributes to default

	for (
	  $i = $self->{'srb'};
	  ($i >= $self->{'srt'}) && ($i > ($self->{'srb'} - $lines));
	  $i --
	) {
		$self->{'scrt'}->[$i] = $a;      # blank new lines
		$self->{'scra'}->[$i] = $b;      # wipe attributes of new lines
	}
}


sub _code_BEL {                         # beep
	my $self = shift;
	$self->callback_call ('BELL', 0, 0);
}

sub _code_BS {                          # move left 1 character
	my $self = shift;
	$self->_code_CUB (1);                         # (cursor left 1)
}

sub _code_CAN {                         # cancel escape sequence
	my $self = shift;
	$self->{'_inesc'} = 0;
	$self->{'_buf'} = undef;
}

sub _code_CHA {                         # move to column in current row
	my $self = shift;
	my $col = shift;
	$col = 1 if (not defined $col);
	return if ($self->{'x'} == $col);
	$self->{'x'} = $col;
	$self->{'x'} = 1 if ($self->{'x'} < 1);
	$self->{'x'} = $self->{'cols'} if ($self->{'x'} > $self->{'cols'});
}

sub _code_CNL {                         # move cursor down and to column 1
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$self->_code_CUD ($num);                      # move down
	$self->_code_CR ();                           # move to column 1
}

sub _code_CPL {                         # move cursor up and to column 1
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$self->_code_CUU ($num);                      # move up
	$self->_code_CR ();                           # move to column 1
}

sub _code_CR {                          # carriage return
	my $self = shift;
	$self->{'x'} = 1;
}

sub _code_CSI {                         # ESC [
	my $self = shift;
	$self->{'_buf'} = '';                         # restart ESC buffering
	$self->{'_inesc'} = 2;                        # ...for a CSI, not an ESC
}

sub _code_CUB {                         # move cursor left
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);
	$self->{'x'} -= $num;
	$self->{'x'} = 1 if ($self->{'x'} < 1);
}

sub _code_CUD {                         # move cursor down
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);
	$self->{'y'} += $num;
	return if ($self->{'y'} <= $self->{'srb'});
	$self->_scroll_down ($self->{'y'} - $self->{'srb'});          # scroll
	$self->{'y'} = $self->{'srb'};
}

sub _code_CUF {                         # move cursor right
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);
	$self->{'x'} += $num;
	$self->{'x'} = $self->{'cols'} if ($self->{'x'} > $self->{'cols'});
}

sub _code_CUP {                         # move cursor to row, column
	my $self = shift;
	my ($row, $col) = (@_);
	$row = 1 if (not defined $row);
	$col = 1 if (not defined $col);
	$row = 1 if ($row < 1);
	$col = 1 if ($col < 1);
	$row = $self->{'rows'} if ($row > $self->{'rows'});
	$col = $self->{'cols'} if ($col > $self->{'cols'});
	$self->{'x'} = $col;
	$self->{'y'} = $row;
}

sub _code_CUU {                         # move cursor up
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);
	$self->{'y'} -= $num;
	return if ($self->{'y'} >= $self->{'srt'});
	$self->_scroll_up ($self->{'srt'} - $self->{'y'});            # scroll
	$self->{'y'} = $self->{'srt'};
}

sub _code_DA {                          # return ESC [ ? 6 c (VT102)
	my $self = shift;
	$self->callback_call ('OUTPUT', "\033[?6c", 0);
}

sub _code_DCH {                         # delete characters on current line
	my $self = shift;
	my $num = shift;
	my ($width, $todel, $line, $lsub, $rsub, $attr);

	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);

	$width = $self->{'cols'} + 1 - $self->{'x'};
	$todel = $num;
	$todel = $width if ($todel > $width);

	$line = $self->{'scrt'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, $self->{'x'} - 1) if ($self->{'x'} > 1);
	$rsub = substr ($line, $self->{'x'} - 1 + $todel);
	$self->{'scrt'}->[$self->{'y'}] = $lsub . $rsub . ("\0" x $todel);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);
	$line = $self->{'scra'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, 2 * ($self->{'x'} - 1)) if ($self->{'x'} > 1);
	$rsub = substr ($line, 2 * ($self->{'x'} - 1 + $todel));
	$self->{'scra'}->[$self->{'y'}] = $lsub . $rsub . ($attr x $todel);

	$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
}

sub _code_DECSTBM {                     # set scrolling region
	my $self = shift;
	my ($top, $bottom) = (@_);
	$top = 1 if (not defined $top);
	$bottom = $self->{'rows'} if (not defined $bottom);
	$top = 1 if ($top < 1);
	$bottom = 1 if ($bottom < 1);
	$top = $self->{'rows'} if ($top > $self->{'rows'});
	$bottom = $self->{'rows'} if ($bottom > $self->{'rows'});
	if ($bottom < $top) {
		my $a = $bottom;
		$bottom = $top;
		$top = $a;
	}
	$self->{'srt'} = $top;
	$self->{'srb'} = $bottom;
}

sub _code_IGN {                         # ignored control sequence
}

sub _code_DL {                          # delete lines
	my $self = shift;
	my $lines = shift;
	my ($attr, $scrb, $row);

	$lines = 1 if (not defined $lines);
	$lines = 1 if ($lines < 1);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	$scrb = $self->{'srb'};
	$scrb = $self->{'rows'} if ($self->{'y'} > $self->{'srb'});
	$scrb = $self->{'srt'} - 1 if ($self->{'y'} < $self->{'srt'});

	for ($row = $self->{'y'}; $row <= ($scrb - $lines); $row ++) {
		$self->{'scrt'}->[$row] = $self->{'scrt'}->[$row + $lines];
		$self->{'scra'}->[$row] = $self->{'scra'}->[$row + $lines];
		$self->callback_call ('ROWCHANGE', $row, 0);
	}

	for (
	  $row = $scrb;
	  ($row > ($scrb - $lines)) && ($row >= ($self->{'y'}));
	  $row --
	) {
		$self->{'scrt'}->[$row] = "\000" x $self->{'cols'};
		$self->{'scra'}->[$row] = $attr x $self->{'cols'};
		$self->callback_call ('ROWCHANGE', $row, 0);
	}
}

sub _code_DSR {                         # device status report
	my $self = shift;
	my $num = shift;
	$num = 5 if (not defined $num);
	if ($num == 6) {                        # CPR - cursor position report
		$self->callback_call (
		  'OUTPUT', "\e[" . $self->{'y'} . ";" . $self->{'x'} . "R", 0
		);
	} elsif ($num == 5) {                   # DSR - reply ESC [ 0 n
		$self->callback_call ('OUTPUT', "\e[0n", 0);
	}
}

sub _code_ECH {                         # erase characters on current line
	my $self = shift;
	my $num = shift;
	my ($width, $todel, $line, $lsub, $rsub, $attr);

	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);

	$width = $self->{'cols'} + 1 - $self->{'x'};
	$todel = $num;
	$todel = $width if ($todel > $width);

	$line = $self->{'scrt'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, $self->{'x'} - 1) if ($self->{'x'} > 1);
	$rsub = substr ($line, $self->{'x'} - 1 + $todel);
	$self->{'scrt'}->[$self->{'y'}] = $lsub . ("\0" x $todel) . $rsub;

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	$line = $self->{'scra'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, 2 * ($self->{'x'} - 1)) if ($self->{'x'}>1);
	$rsub = substr ($line, 2 * ($self->{'x'} - 1 + $todel));
	$self->{'scra'}->[$self->{'y'}] = $lsub . ($attr x $todel) . $rsub;

	$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
}

sub _code_ED {                          # erase display
	my $self = shift;
	my $num = shift;
	my ($row, $attr);

	$num = 0 if (not defined $num);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	# Wipe-cursor-to-end is the same as clear-whole-screen if cursor at top left
	#
	$num = 2 if (($num == 0) && ($self->{'x'} == 1) && ($self->{'y'} == 1));

	if ($num == 0) {                              # 0 = cursor to end
		$self->{'scrt'}->[$self->{'y'}] =
		  substr (
		    $self->{'scrt'}->[$self->{'y'}],
		    0,
		    $self->{'x'} - 1
		  ) . ("\0" x ($self->{'cols'} + 1 - $self->{'x'}));
		$self->{'scra'}->[$self->{'y'}] =
		  substr (
		    $self->{'scra'}->[$self->{'y'}],
		    0,
		    2 * ($self->{'x'} - 1)
		  ) . ($attr x ($self->{'cols'} + 1 - $self->{'x'}));
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
		for (
		  $row = $self->{'y'} + 1;
		  $row <= $self->{'rows'};
		  $row ++
		) {
			$self->{'scrt'}->[$row] = "\0" x $self->{'cols'};
			$self->{'scra'}->[$row] = $attr x $self->{'cols'};
			$self->callback_call ('ROWCHANGE', $row, 0);
		}
	} elsif ($num == 1) {                         # 1 = start to cursor
		for (
		  $row = 1;
		  $row < $self->{'y'};
		  $row ++
		) {
			$self->{'scrt'}->[$row] = "\0" x $self->{'cols'};
			$self->{'scra'}->[$row] = $attr x $self->{'cols'};
			$self->callback_call ('ROWCHANGE', $row, 0);
		}
		$self->{'scrt'}->[$self->{'y'}] =
		  ("\0" x $self->{'x'}) .
		  substr ($self->{'scrt'}->[$self->{'y'}], $self->{'x'});
		$self->{'scra'}->[$self->{'y'}] =
		  ($attr x $self->{'x'}) .
		  substr ($self->{'scra'}->[$self->{'y'}], 2 * $self->{'x'});
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
	} else {                                      # 2 = whole display
		$self->callback_call ('CLEAR', 0, 0);
		for ($row = 1; $row <= $self->{'rows'}; $row ++) {
			$self->{'scrt'}->[$row] = "\0" x $self->{'cols'};
			$self->{'scra'}->[$row] = $attr x $self->{'cols'};
		}
	}
}

sub _code_EL {                          # erase line
	my $self = shift;
	my $num = shift;
	my $attr;

	$num = 0 if (not defined $num);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	if ($num == 0) {                            # 0 = cursor to end of line
		$self->{'scrt'}->[$self->{'y'}] =
		  substr (
		    $self->{'scrt'}->[$self->{'y'}],
		    0,
		    $self->{'x'} - 1
		  ) . ("\0" x ($self->{'cols'} + 1 - $self->{'x'}));
		$self->{'scra'}->[$self->{'y'}] =
		  substr (
		    $self->{'scra'}->[$self->{'y'}],
		    0,
		    2 * ($self->{'x'} - 1)
		  ) . ($attr x ($self->{'cols'} + 1 - $self->{'x'}));
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
	} elsif ($num == 1) {                       # 1 = start of line to cursor
		$self->{'scrt'}->[$self->{'y'}] =
		  ("\0" x $self->{'x'}) .
		  substr ($self->{'scrt'}->[$self->{'y'}], $self->{'x'});
		$self->{'scra'}->[$self->{'y'}] =
		  ($attr x $self->{'x'}) .
		  substr ($self->{'scra'}->[$self->{'y'}], 2 * $self->{'x'});
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
	} else {                                      # 2 = whole line
		$self->{'scrt'}->[$self->{'y'}] = "\0" x $self->{'cols'};
		$self->{'scra'}->[$self->{'y'}] = $attr x $self->{'cols'};
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
	}
}

sub _code_ESC {                         # start escape sequence
	my $self = shift;
	$self->{'_buf'} = '';                         # set ESC buffer
	$self->{'_inesc'} = 1;                        # ...for ESC, not CSI
}

sub _code_LF {                          # line feed
	my $self = shift;
	$self->_code_CR ()                            # cursor to start of line
	  if ($self->{'opts'}->{'LFTOCRLF'} != 0);
	$self->_code_CUD (1);                         # cursor down
}

sub _code_HT {                          # horizontal tab to next tab stop
	my $self = shift;
	my ($newx, $spaces, $width);

	$newx = $self->{'x'};
	$newx ++;
	while ((($newx - 1) % 8) != 0) { $newx ++; }

	$width = ($self->{'cols'} + 1) - $self->{'x'};
	$spaces = $newx - $self->{'x'};
	$spaces = $width + 1 if ($spaces > $width);

	$self->_code_CUF ($spaces) if ($spaces > 0);
}

sub _code_ICH {                         # insert blank characters
	my $self = shift;
	my $num = shift;
	my ($width, $toins, $line, $lsub, $rsub, $attr);

	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);

	$width = $self->{'cols'} + 1 - $self->{'x'};
	$toins = $num;
	$toins = $width if ($toins > $width);

	$line = $self->{'scrt'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, $self->{'x'} - 1) if ($self->{'x'} > 1);
	$rsub = substr ($line, $self->{'x'} - 1, $width - $toins);
	$self->{'scrt'}->[$self->{'y'}] = $lsub . ("\0" x $toins) . $rsub;

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);
	$line = $self->{'scra'}->[$self->{'y'}];
	($lsub, $rsub) = ("", "");
	$lsub = substr ($line, 0, 2 * ($self->{'x'} - 1)) if ($self->{'x'} > 1);
	$rsub = substr ($line, 2 * ($self->{'x'} - 1), 2 * ($width - $toins));
	$self->{'scra'}->[$self->{'y'}] = $lsub . ($attr x $toins) . $rsub;

	$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
}

sub _code_IL {                          # insert blank lines
	my $self = shift;
	my $lines = shift;
	my ($attr, $scrb, $row);

	$lines = 1 if (not defined $lines);
	$lines = 1 if ($lines < 1);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	$scrb = $self->{'srb'};
	$scrb = $self->{'rows'} if ($self->{'y'} > $self->{'srb'});
	$scrb = $self->{'srt'} - 1 if ($self->{'y'} < $self->{'srt'});

	for ($row = $scrb; $row >= ($self->{'y'} + $lines); $row --) {
		$self->{'scrt'}->[$row] = $self->{'scrt'}->[$row - $lines];
		$self->{'scra'}->[$row] = $self->{'scra'}->[$row - $lines];
		$self->callback_call ('ROWCHANGE', $row, 0);
	}

	for (
	  $row = $self->{'y'};
	  ($row <= $scrb) && ($row < ($self->{'y'} + $lines));
	  $row ++
	) {
		$self->{'scrt'}->[$row] = "\000" x $self->{'cols'};
		$self->{'scra'}->[$row] = $attr x $self->{'cols'};
		$self->callback_call ('ROWCHANGE', $row, 0);
	}
}

sub _code_OSC {                         # operating system command
	my $self = shift;
	$self->{'_buf'} = '';                         # restart buffering
	$self->{'_inesc'} = 3;                        # ...for OSC, not ESC or CSI
}

sub _code_RIS {                         # reset
	my $self = shift;
	$self->reset ();
}

sub _code_SGR {                         # set graphic rendition
	my $self = shift;
	my (@parms) = (@_);
	my ($val, $fg, $bg, $bo, $fa, $st, $ul, $bl, $rv);

	($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv) =
	  $self->attr_unpack ($self->{'attr'});

	@parms = (0) if ($#parms < 0);                # ESC [ m = ESC [ 0 m

	while (defined ($val = shift @parms)) {
		if ($val == 0) {                     # reset all attributes
			($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv) =
			  (7, 0, 0, 0, 0, 0, 0, 0);
		} elsif ($val == 1) {                # bold ON
			($bo, $fa) = (1, 0);
		} elsif ($val == 2) {                # faint ON
			($bo, $fa) = (0, 1);
		} elsif ($val == 4) {                # underline ON
			$ul = 1;
		} elsif ($val == 5) {                # blink ON
			$bl = 1;
		} elsif ($val == 7) {                # reverse video ON
			$rv = 1;
		} elsif ($val == 21) {               # normal intensity
			($bo, $fa) = (0, 0);
		} elsif ($val == 22) {               # normal intensity
			($bo, $fa) = (0, 0);
		} elsif ($val == 24) {               # underline OFF
			$ul = 0;
		} elsif ($val == 25) {               # blink OFF
			$bl = 0;
		} elsif ($val == 27) {               # reverse video OFF
			$rv = 0;
		} elsif (($val >= 30) && ($val <= 37)) {# set foreground colour
			$fg = $val - 30;
		} elsif ($val == 38) {               # underline on, default fg
			($ul, $fg) = (1, 7);
		} elsif ($val == 39) {               # underline off default fg
			($ul, $fg) = (0, 7);
		} elsif (($val >= 40) && ($val <= 47)) {# set background colour
			$bg = $val - 40;
		} elsif ($val == 49) {               # default background
			$bg = 0;
		}
	}

	$self->{'attr'} = $self->attr_pack ($fg, $bg, $bo, $fa, $st, $ul, $bl, $rv);
}

sub _code_VPA {                         # move to row (current column)
	my $self = shift;
	my $row = shift;
	$row = 1 if (not defined $row);
	return if ($self->{'y'} == $row);
	$self->{'y'} = $row;
	$self->{'y'} = 1 if ($self->{'y'} < 1);
	$self->{'y'} = $self->{'rows'} if ($self->{'y'} > $self->{'rows'});
}

sub _code_DECALN {                      # fill screen with E's
	my $self = shift;
	my ($row, $attr);

	$attr = $self->attr_pack (7, 0, 0, 0, 0, 0, 0, 0);

	for ($row = 1; $row <= $self->{'rows'}; $row ++) {
		$self->{'scrt'}->[$row] = 'E' x $self->{'cols'};
		$self->{'scra'}->[$row] = $attr x $self->{'cols'};
		$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
	}

	$self->{'x'} = 1;
	$self->{'y'} = 1;
}

1;
__END__

=head1 NAME

Term::VT102 - a class to emulate a DEC VT102 terminal

=head1 SYNOPSIS

  use Term::VT102;

  my $vt = Term::VT102->new ('cols' => 80, 'rows' => 24);
  while (<>) { $vt->process ($_); }

=head1 DESCRIPTION

The VT102 class provides emulation of most of the functions of a DEC VT102
terminal.  Once initialised, data passed to a VT102 object is processed and the
in-memory "screen" modified accordingly.  This "screen" can be interrogated by
the external program in a variety of ways.

This allows your program to interface with full-screen console programs by
running them in a subprocess and passing their output to a VT102 class.  You
can then see what the application has written on the screen by querying the
class appropriately.

=head1 OPTIONS

Setting B<cols> or B<rows> in the B<new()> hash allows you to change
the size of the terminal being emulated.  If you do not specify a size, the
default is 80 columns by 24 rows.

After initialisation, you can read and set the following terminal options
using the B<option_read()> and B<option_set()> methods:

  LINEWRAP      line wrapping; 1=on, 0=off. Default is OFF.
  LFTOCRLF      treat LF (\n) as CRLF (\r\n); 1=on, 0=off. Default OFF.

=head1 METHODS

The following methods are provided:

=over 4

=item B<attr_pack> (I<$fg>,I<$bg>,I<$bo>,I<$fa>,I<$st>,I<$ul>,I<$bl>,I<$rv>)

Returns the packed version of the given attribute settings, which are given in
the same order as returned by B<attr_unpack>.  The packed version will be a
binary string not longer than 2 bytes.

=item B<attr_unpack> (I<$data>)

Returns a list of the contents of the given packed attribute settings, of the
form (I<$fg>,I<$bg>,I<$bo>,I<$fa>,I<$st>,I<$ul>,I<$bl>,I<$rv>).

I<$fg> and I<$bg> are the ANSI foreground and background text colours, and
I<$bo>, I<$fa>, I<$st>, I<$ul>, I<$bl>, and I<$rv> are flags (1 = on,
0 = off) for bold, faint, standout, underline, blink and reverse respectively.

=item B<callback_call> (I<$name>, I<$par1>, I<$par2>)

Calls the callback I<$name> (eg B<'ROWCHANGE'>) with parameters
I<$par1> and I<$par2>, as if the VT102 module had called it.
Does nothing if that callback has not been set with
B<callback_set ()>.

=item B<callback_set> (I<$callback>, I<$ref>, I<$private>)

Sets the callback I<callback> to function reference I<ref> with
private data I<$private>.

See the section on B<CALLBACKS> below.

=item B<new> (I<%config>)

Returns a new VT102 object with options specified in I<%config> (see the
B<OPTIONS> section for details).

=item B<option_read> (I<$option>)

Returns the current value of terminal option I<$option> (see B<OPTIONS> for
details), or I<undef> if that option does not exist.  Note that you cannot
read the terminal size with this call; use B<size()> for that.

=item B<option_set> (I<$option>, I<$value>)

Sets the current value of terminal option I<$option> to I<$value>, returning
the old value or I<undef> if no such terminal option exists or you have
specified an undefined I<$value>.  Note that you cannot resize the terminal
with this call; use B<resize()> for that.

=item B<process> (I<$string>)

Processes the string I<$string> (which can be zero-length), updating the
VT102 object accordingly and calling any necessary callbacks on the way.

=item B<resize> (I<$cols>, I<$rows>)

Resizes the VT102 terminal to I<cols> columns by I<rows> rows,
eg B<$vt->>B<resize (80, 24)>.  The virtual screen is cleared first.

=item B<reset> ()

Resets the object to its "power-on" state.

=item B<row_attr> (I<$row>, [I<$startcol>, I<$endcol>])

Returns the attributes for row I<$row> (or I<undef> if out of range) as
a string of packed attributes, each character cell's attributes being 2
bytes long.  To unpack the attributes for a given cell, use B<substr()>,
eg B<$attr=substr($row,4,2)> would set I<$attr> to the attributes for cell
3 (steps of 2: 0 .. 2 .. 4, so 4 means the 3rd character).  You would then
use the B<attr_unpack()> method to unpack that character cell's attributes.

If I<$startcol> and I<$endcol> are defined, only returns the part of the row
between columns I<$startcol> and I<$endcol> inclusive instead of the whole row.

=item B<row_plaintext> (I<$row>, [I<$startcol>, I<$endcol>])

Returns the textual contents of row I<$row> (or I<undef> if out of range),
with unused characters being represented as spaces.  If I<$startcol> and
I<$endcol> are defined, only returns the part of the row between columns
I<$startcol> and I<$endcol> inclusive instead of the whole row.

=item B<row_text> (I<$row>, [I<$startcol>, I<$endcol>])

Returns the textual contents of row I<$row> (or I<undef> if out of range), with
totally unused characters being represented as NULL (\0).  If I<$startcol> and
I<$endcol> are defined, only returns the part of the row between columns
I<$startcol> and I<$endcol> inclusive instead of the whole row.

=item B<cols> ()

Return the number of columns in the VT102 object.

=item B<rows> ()

Return the number of rows in the VT102 object.

=item B<size> ()

Return a pair of values (I<columns>,I<rows>) denoting the size of the terminal
in the VT102 object.

=item B<x> ()

Return the current cursor X co-ordinate (1 being leftmost).

=item B<y> ()

Return the current cursor Y co-ordinate (1 being topmost).

=item B<xtitle> ()

Return the current xterm window title.

=item B<xicon> ()

Return the current xterm window icon name.

=item B<status> ()

Return a list of values
(I<$x>,I<$y>,I<$attr>,I<$ti>,I<$ic>), where I<$x> and I<$y> are the cursor
co-ordinates (1,1 = top left), I<$attr> is a packed version of the current
attributes (see B<attr_unpack>), I<$ti> is the xterm window title, and
I<$ic> is the xterm window icon name.

=item B<version> ()

Return the version of the VT102 module being used.

=back

=head1 CALLBACKS

Callbacks are the processing loop's way of letting your main program know
that something has happened.  They are called while in a B<process()> loop.

To specify a callback, use the B<callback_set> interface, giving a reference
to the function to call.  Your function should take five scalar arguments:
the VT102 object being processed, the name of the callback, and two
arguments whose value depends on the callback, as shown below.  The final
argument is the private data scalar you passed when you called
B<callback_set>.

The name of the callback is passed to the callback function so that you can
have one function to handle all callbacks if you wish.

Available callback names are:

  BELL          BEL (beep, \007) character received
  CLEAR         screen about to be cleared
  OUTPUT        data (arg1) to be sent back to data source
  ROWCHANGE     screen row (row number is argument 1) content has changed
  SCROLL_DOWN   about to scroll down (arg1=top row, arg2=num to scroll)
  SCROLL_UP     about to scroll up (ditto)
  UNKNOWN       unknown/unsupported code (arg1=name, arg2=code/sequence)
  XICONNAME     xterm icon name to be changed to arg1
  XWINTITLE     xterm title name to be changed to arg2

Note that the wording of the above is significant in terms of exactly
B<when> the callback is called. For instance, B<CLEAR> is called just
before the screen is cleared, whereas B<ROWCHANGE> is called I<after>
the given row has been changed.

A good callback handler for B<OUTPUT> is to simply B<syswrite()> argument 1
to your data source - eg if you're reading from a telnet session, write
that argument straight to it.  It is used for cursor position request
responses and suchlike.

Note that B<SCROLL_DOWN> is called when scrolling down, so text is about to
move UP the screen; I<arg1> will be the row number of the bottom of the
scrolling region, and I<arg2> will be the number of rows to be scrolled.
Likewise, B<SCROLL_UP> is called when text is about to move down; I<arg1>
will be the row number of the top of the scrolling region.

Finally, note that B<ROWCHANGE> is only triggered when text is being entered;
screen scrolling or screen clearance does not trigger it, that would
trigger a B<SCROLL_DOWN> or B<SCROLL_UP> or B<CLEAR>.  Line or character
insertion or deletion will cause one or more B<ROWCHANGE> callbacks, however.

=head1 SUPPORTED CODES

The following sequences are supported:

   007 (BEL)   beep
   010 (BS)    backspace
   011 (HT)    horizontal tab to next tab stop
   012 (LF)    line feed
   013 (VT)    line feed
   014 (FF)    line feed
   015 (CR)    carriage return
   030 (CAN)   interrupt escape sequence
   032 (SUB)   interrupt escape sequence
   033 (ESC)   start escape sequence
   177 (DEL)   ignored
   233 (CSI)   same as ESC [

   ESC # 8 (DECALN)  DEC screen alignment test - fill screen with E's

   CSI @ (ICH)     insert blank characters
   CSI A (CUU)     move cursor up
   CSI B (CUD)     move cursor down
   CSI C (CUF)     move cursor right
   CSI D (CUB)     move cursor left
   CSI E (CNL)     move cursor down and to column 1
   CSI F (CPL)     move cursor up and to column 1
   CSI G (CHA)     move cursor to column in current row
   CSI H (CUP)     move cursor to row, column
   CSI J (ED)      erase display
   CSI K (EL)      erase line
   CSI L (IL)      insert blank lines
   CSI M (DL)      delete lines
   CSI P (DCH)     delete characters on current line
   CSI X (ECH)     erase characters on current line
   CSI a (HPR)     move cursor right
   CSI c (DA)      return ESC [ ? 6 c (VT102)
   CSI d (VPA)     move to row (current column)
   CSI e (VPR)     move cursor down
   CSI f (HVP)     move cursor to row, column
   CSI m (SGR)     set graphic rendition
   CSI n (DSR)     device status report
   CSI r (DECSTBM) set scrolling region to (top, bottom) rows
   CSI ` (HPA)     move cursor to column in current row

=head1 LIMITATIONS

Unknown escape sequences and control characters are ignored.  All escape
sequences pertaining to character sets are ignored.

The following known control characters / sequences are ignored:

   005 (ENQ)         trigger answerback message
   021 (XON)         resume transmission
   023 (XOFF)        stop transmission

   ESC 7  (DECSC)    save state
   ESC 8  (DECRC)    restore most recently saved state
   ESC >  (DECPNM)   set numeric keypad mode
   ESC =  (DECPAM)   set application keypad mode
   ESC H  (HTS)      set tab stop at current column
   ESC P  (DCS)      device control string (ended by ST)
   ESC X  (SOS)      start of string
   ESC ^  (PM)       privacy message (ended by ST)
   ESC \  (ST)       string terminator

   CSI g (TBC)       clear tab stop (CSI 3 g = clear all stops)
   CSI h (SM)        set mode
   CSI l (RM)        reset mode
   CSI q (DECLL)     set keyboard LEDs
   CSI s (CUPSV)     save cursor position
   CSI u (CUPRS)     restore cursor position

=head1 EXAMPLES

For some examples, including how to interface Term::VT102 with Net::Telnet,
please see the B<examples/> directory in the distribution.

=head1 AUTHORS

Copyright (C) 2002 Andrew Wood C<E<lt>andrew.wood@ivarch.comE<gt>>.
Distributed under the terms of the Artistic License.

Credit is also due to:

  Charles Harker <CHarker@interland.com>
    - reported and helped to diagnose a bug in the handling of TABs

  Steve van der Burg <steve.vanderburg@lhsc.on.ca>
    - supplied basis for an example script using Net::Telnet

=head1 SEE ALSO

B<console_codes>(4)

=cut

# EOF $Id: VT102.pm,v 1.5 2002/08/04 20:18:23 ivarch Exp $
