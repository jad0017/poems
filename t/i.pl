#!/usr/bin/perl
use strict;
use warnings;

# XXX Not perfect. check https://xapian.org/docs/stemming.html
use Lingua::EN::Infinitive;

open(my $f, '<', $ARGV[0]) or die qq($!\n);
my @words;
while (my $line = <$f>) {
	chomp $line;
	push @words, ( split /\s+/, $line );
}
close $f;

my $spell = Lingua::EN::Infinitive->new();

for my $i ( 0 .. $#words ) {
	my $orig = $words[$i];
	my ($in1, $in2, @a) = $spell->stem($orig);
	print "$i: $orig\t$in1\t$in2\n";
}
