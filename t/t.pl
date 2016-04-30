#!/usr/bin/perl
my %words;

while (my $line = <>) {
	$line = lc $line;
	$line =~ s/(i|you|they|she)'ll/$1 will/g;
	$line =~ s/(it|there)'s/$1 is/g;
	$line =~ s/(does|was|are|should)n't/$1 not/g;
	$line =~ s/(can|do)n?'t/$1 not/g;
	$line =~ s/won't/will not/g;
	$line =~ s/you're/you are/g;
	$line =~ s/i'm/i am/g;
	$line =~ s/i've/i have/g;
	$line =~ s/[.?:,!;-]//g;

	my @a = split(/\s+/, $line);

	for my $w ( @a ) {
		$words{ $w }++;
	}
}

print "Number of Words: ", scalar keys %words, qq(\n);
print "-----------------------------\n";

my @keys = sort {
	return -1 if ( $words{ $a } > $words{ $b } );
	return 1 if ( $words{ $a } < $words{ $b } );
	-($a cmp $b);
} keys %words;

for my $key ( @keys ) {
	printf "%15s : %d\n", $key, $words{ $key };
}
