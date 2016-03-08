use strict;
use warnings;

use List::Util qw(shuffle);

die qq(usage: $0 <file...>\n) if ( scalar(@ARGV) == 0 );

my %uniq;
my @words;

for my $file ( @ARGV ) {
	open(my $fd, '<', $file)
		or die qq(Failed to open file($file): $!\n);

	while ( my $line = <$fd> ) {
		next if ( $line =~ m/^\s*#/o );
		my @a = split(/\s+/, $line);

		for my $w ( @a ) {
			$uniq{ $w }++;
			push @words, $w;
		}
	}

	close $fd;
}

printf qq(Total Words:  %d\n), scalar( @words );
printf qq(Unique Words: %d\n), scalar( keys %uniq );
print qq(\n);

my @words_shuffled = shuffle @words;

for my $i ( 0 .. 9 ) {
	my $shift = $i * 4;
	printf qq(%d: %s\n), $i,
		join(' ', @words_shuffled[ (0 + $shift) .. (3 + $shift) ]);
}

