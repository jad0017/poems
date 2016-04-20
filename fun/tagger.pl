use strict;
use warnings;

use Lingua::EN::Tagger;
use List::Util qw(shuffle);

open(my $f, '<', $ARGV[0]) or die qq($!\n);
my $text = '';
while (my $line = <$f>) {
	chomp $line;
	$text .= qq( $line);
}
close $f;

my $parser = new Lingua::EN::Tagger;
my $sentences = $parser->get_sentences($text);
#print scalar(@{ $sentences} );
#my $tagged_text = $parser->add_tags($text);
#print $tagged_text,qq(\n);

# See: comp.leeds.ac.uk/ccalas/tagsets/upenn.html
my %penn_treebank_tags = (
'$' => 'DOLLAR',
'``' => 'QUOTE_OPEN',
'"' => 'QUOTE_CLOSE',
'(' => 'PAREN_OPEN',
')' => 'PAREN_CLOSE',
',' => 'COMMA',
'--' => 'DASH',
'.' => 'SENT_TERMINATOR',
':' => 'COLON_OR_ELLIPSE',
'CC' => 'COORDINATING_CONJUNCTION',
'CD' => 'CARDINAL_NUMERAL',
'DT' => 'DETERMINER',
'DET' => 'DETERMINER_DET',
'EX' => 'EXISTENTIAL_THERE',
'FW' => 'FOREIGHN_WORD',
'IN' => 'PREPOSITION_OR_SUBORDINATING_CONJUNCTION',
'JJ' => 'ADJECTIVE_OR_ORDINAL_NUMERAL',
'JJR' => 'COMPARATIVE_ADJECTIVE',
'JJS' => 'SUPERLATIVE_ADJECTIVE',
'LS' => 'LIST_ITEM_MARKER',
'MD' => 'MODAL_AUXILLARY',
'NN' => 'SING_COMMON_OR_MASS_NOUN',
'NNP' => 'PROPER_SING_NOUN',
'NNPS' => 'PROPER_PLUR_NOUN',
'NNS' => 'PLUR_COMMON_NOUN',
'PDT' => 'PRE_DETERMINER', # all both half many quite such sure this
'POS' => 'GENITIVE_MARKER', # ''s
'PP' => 'SENT_TERMINATOR_PP',
'PPS' => 'PUNCTUATION_SEP_PPS',
'PRP' => 'PERSONAL_PRONOUN',
'PRP$' => 'POSSESSIVE_PRONOUN',
'PRPS' => 'POSSESSIVE_PRONOUN_S',
'RB' => 'ADVERB',
'RBR' => 'COMPARATIVE_ADVERB',
'RBS' => 'SUPERLATIVE_ADVERB',
'RP' => 'PARTICLE', # ??
'SYM' => 'SYMBOL',
'TO' => 'TO_AS_PREP_OR_INFINITIVE', # Just 'to'
'UH' => 'INTERJECTION',
'VB' => 'BASE_FORM_VERB',
'VBD' => 'PAST_TENSE_VERB',
'VBG' => 'PRESENT_PART_OR_GERUND_VERB',
'VBN' => 'PAST_PART_VERB',
'VBP' => 'PRESENT_TENSE_VERB_NO_3RD',
'VBZ' => 'PRESENT_TENSE_3RD_PERSON_VERB',
'WDT' => 'WH_DETERMINER', # that what whatever which whichever
'WP' => 'WH_PRONOUN', # that what whatever whatsoever which who whom whosoever
'WP$' => 'POSSESSOVE_WH_PRONOUN', # whose
'WPS' => 'POSSESSOVE_WH_PRONOUN_S', # whose
'WRB' => 'WH_ADVERB', # how however whenever where whereby ...
);


sub sep(){ print(q(-) x 79, qq(\n)); }
sub Sep(){ print(q(=) x 79, qq(\n)); }

my $i = 0;
for my $s ( @{ $sentences } ) {
	my $tag = $parser->get_readable($s);
	for my $k ( keys %penn_treebank_tags ) {
		my $v = $penn_treebank_tags{ $k };
		$tag =~ s|\Q/$k\E\b|/$v|g
	}
	print qq($i: $tag\n);
	sep;
	$i++;
}
undef $sentences;

Sep;
print qq(Nouns:\n);
Sep;
$i = 0;
my %noun_list = $parser->get_words($text);
for my $k ( keys %noun_list ) {
	my $v = $noun_list{ $k };
	print qq($i: $k    $v\n);
	sep;
	$i++;
}

sub get_exp {
	my ($tag) = @_;
	return unless defined $tag;
	return qr|<$tag>[^<]+</$tag>\s*|;
}

my $NUM   = get_exp('cd');
my $GER   = get_exp('vbg');
my $ADJ   = get_exp('jj[rs]*');
my $PART  = get_exp('vbn');
my $NN    = get_exp('nn[sp]*');
my $NNP   = get_exp('nnp');
my $PREP  = get_exp('in');
my $DET   = get_exp('det');
my $PAREN = get_exp('[lr]rb');
my $QUOT  = get_exp('ppr');
my $SEN   = get_exp('pp');
my $AUX   = get_exp('md');
my $ADV   = get_exp('w?rb[rs]*');
my $VERB  = get_exp('vb[hdnpz]*');
my $WORD  = get_exp('\p{IsWord}+');

sub get_verbs {
	my ($parser, $text, $max) = @_;
	$max = 5 unless defined $max;

	my $MVP = qr/
		(?:$VERB|$ADV)+      # One or more verb and adverb
		(?:$GER|$ADJ|$PART)* # Followed by one or more gerund, adj, or part.
		(?:
		    (?:$PREP)*(?:$DET)?(?:$NUM)?(?:$ADV)?  # ??
			(?:$GER|$ADJ|$PART|$ADV)*  # WAT?
			(?:$VERB)+  # WATTTTT???
		)*
	/xo;
	#my $MVP = qr/(?:$AUX|$ADV|$VERB)*(?:$VERB)/o;

	my $tagged = $parser->add_tags($text);

	my $found;
	my $phrase_ext = qr/(?:$AUX|$ADV|$DET|$PREP|$ADJ|$NUM|$NN|$VERB)+/xo;

	my @mn_phrases = map {
		$found->{ $_ }++ if m/$phrase_ext/;
		split /$phrase_ext/;
	} ( $tagged =~ /($MVP)/gs );

	for (@mn_phrases) {
		my @words = split;

		for (0 .. $#words) {
			$found->{ join(" ", @words) }++ if (scalar(@words) > 1);
			my $w = shift @words;
			$found->{ $w }++ if ( $w =~ /$VERB/ );
		}
	}

	my %ret;

	for ( keys %{ $found } ) {
		my $k = $parser->_strip_tags($_);
		my $v = $found->{ $_ };

		my @space_count = $k =~ /\s+/go;
		my $word_count = scalar(@space_count) + 1;

		next if $word_count > $max;

		$k = $parser->stem($k) unless $word_count > 1;
		my $multiplier = 1;
		$multiplier = $word_count if $max;
		$ret{ $k } += ( $multiplier * $v );
	}

	return %ret;
}

sub get_verbs2 {
	my ($parser, $text, $max) = @_;
	$max = 5 unless defined $max;

	my $tagged = $parser->add_tags($text);

	my %r;

	print "$text\n";
	print "$VERB\n";

	while ( my $m = ($tagged =~ m/($VERB)/g) ) {
		my $t = $parser->_strip_tags($m);
		$r{ $t } = 1;
	}

	return %r;
}

Sep;
print qq(Verbs:\n);
Sep;
$i = 0;
my %verb_list = get_verbs($parser, $text);
for my $k ( keys %verb_list ) {
	my $v = $verb_list{ $k };
	print qq($i: $k    $v\n);
	sep;
	$i++;
}
undef $text;

sub sort_hash {
	sort {
		my $c = $_[0]->{ $a } <=> $_[0]->{ $b };
		return -($c) if $c;
		-($a cmp $b);
	} ( keys %{ $_[0] } );
}

my @nouns = sort_hash(\%noun_list);
my @high_nouns;
for my $x ( @nouns ) {
	push(@high_nouns, $x) if $noun_list{ $x } > 1;
}
undef %noun_list;

my @verbs = sort_hash(\%verb_list);
my @high_verbs;

for my $x ( @verbs ) {
	push(@high_verbs, $x) if $verb_list{ $x } > 1;
}
undef %verb_list;

Sep;
print qq(Top Result:\n);
Sep;
my $n = $nouns[0];
my $v = $verbs[0];
my $n2 = $nouns[1];
print qq($v (the) $n\n);
print qq($n (the/that) $v $n2\n);
sep;

Sep;
print qq(Other:\n);
Sep;

my @s_high_nouns;
my @s_high_verbs;

if ( @high_nouns ) {
	@s_high_nouns = shuffle(@high_nouns);
	undef @high_nouns;
} else {
	@s_high_nouns = shuffle(@nouns);
}

if ( @high_verbs ) {
	@s_high_verbs = shuffle(@high_verbs);
	undef @high_verbs;
} else {
	@s_high_verbs = shuffle(@verbs);
}

for my $x ( 0 .. 9 ) {
	my $t = shift @s_high_nouns;
	$t = shift @nouns unless ( defined $t );
	$n = $t if defined $t;
	$t = shift @s_high_verbs;
	$t = shift @verbs unless ( defined $t );
	$v = $t if defined $t;
	$t = shift @s_high_nouns;
	$t = shift @nouns unless ( defined $t );
	$n2 = $t if defined $t;

	print qq($x: $v (the) $n\n);
	print qq($x: $n (the/that) $v $n2\n);
	sep;
}
