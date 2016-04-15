package Syllable;

use strict;
use warnings;

my @SubSyl = (
	qr|cial|o,
	qr|tia|o,
	qr|cius|o,
	qr|cious|o,
	qr|giu|o,
	qr|ion|o,
	qr|iou|o,
	qr|sia$|o,
	qr|.ely$|o,
);

my @AddSyl = (
	qr|ia|o,
	qr|riet|o,
	qr|iu|o,
	qr|io|o,
	qr|ii|o,
	qr|[aeiouym]bl$|o,
	qr|[aeiou]{3}|o,
	qr|^mc|o,
	qr|ism$|o,
	qr|([^aeiouy])\1l$|o,
	qr|[^l]lien|o,
	qr|^coa[dglx].|o,
	qr|[^gq]ua[^auieo]|p,
	qr|dnt$|o,
);

sub Syllables($) {
	my $word = lc $_[0];
	$word =~ s/['.?~,;"-]+//go;

	return 1 if ( $word =~ m/^.he$/o );

	$word =~ s/e$//o;

	my @scrugg = split m/[^aeiouy]+/o, $word;
	shift(@scrugg) if ( @scrugg and $scrugg[0] eq '' );
	my $syl = 0;

	for ( @SubSyl ) {
		--$syl if ( $word =~ m/$_/ );
	}

	for ( @AddSyl ) {
		++$syl if ( $word =~ m/$_/ );
	}

	++$syl if ( length($word) == 1 ); # 'a'

	# Count vowel grouping
	$syl += scalar(@scrugg) unless ( scalar(@scrugg) == 1 and $syl );

	# If no vowels: 'crwth'
	$syl = length($word) unless ( $syl ); # or $syl = 1?

	$syl;
}

1;
