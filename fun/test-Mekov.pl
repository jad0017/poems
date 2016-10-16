#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Mekov;

die "usage: $0 <filename...>\n"
	unless ( @ARGV );

my $m = new Mekov;

for my $file ( @ARGV ) {
	$m->init($file);
}

for my $x ( 0 .. 20 ) {
	my $line = $m->genSentence(10);
	my @a = split /\s+/, $line;
	next if ( scalar @a < 4 );
	print '"', $m->genSentence(10), "\"\n";
	#exit;
}
print '"', $m->genSentence(10), "\"\n";
#exit;

my $x = 0;
for $x ( 0 .. 20 ) {
	print "$x: ", $m->genSentence(10), "\n";
}

