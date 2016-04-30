#!/usr/bin/perl
use strict;
use warnings;

use Lingua::EN::Tagger;

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

Sep;
print qq(Nouns:\n);
Sep;
$i = 0;
my %word_list = $parser->get_words($text);
for my $k ( keys %word_list ) {
	my $v = $word_list{ $k };
	print qq($i: $k    $v\n);
	sep;
	$i++;
}
