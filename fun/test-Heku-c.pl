#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use HekuC;

die "usage: $0 <filename...>\n"
	unless ( @ARGV );

my $m = new HekuC;

$m->init_array( @ARGV );
my @a = split(m|\s*/\s*|, $m->GenHaiku((1 .. 30)));
for my $i ( 0 .. $#a ) {
	print q(    ), $a[ $i ], qq(\n);
}

