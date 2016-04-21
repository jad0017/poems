package Uncontract;

use strict;
use warnings;

# Source: wikipedia.org/wiki/Wikipedia:List_of_English_contractions
my @contractions = (
	[ q(ain't), q(am not) ],
	[ q(amn't), q(am not) ],
	[ q(aren't), q(are not) ],
	[ q(can't), q(can not) ],
	[ q(could've), q(could have) ],
	[ q(couldn't), q(could not) ],
	[ q(couldn't've), q(could not have) ],
	[ q(didn't), q(did not) ],
	[ q(doesn't), q(does not) ],
	[ q(don't), q(do not) ],
	[ q(gonna), q(going to) ],
	[ q(hadn't), q(had not) ],
	[ q(hadn't've), q(had not have) ],
	[ q(hasn't), q(has not) ],
	[ q(haven't), q(have not) ],
	[ q(he'd), q(he had), q(he would) ],
	[ q(he'd've), q(he would have) ],
	[ q(he'll), q(he shall), q(he will) ],
	[ q(he's), q(he has), q(he is) ],
	[ q(he'sn't), q(he has not), q(he is not) ],
	[ q(how'd), q(how did), q(how would) ],
	[ q(how'll), q(how will) ],
	[ q(how's), q(how has), q(how is), q(how does) ],
	[ q(I'd), q(I had), q(I would) ],
	[ q(I'd've), q(I would have) ],
	[ q(I'll), q(I shall), q(I will) ],
	[ q(I'm), q(I am) ],
	[ q(I've), q(I have) ],
	[ q(I'ven't), q(I have not) ],
	[ q(isn't), q(is not) ],
	[ q(it'd), q(it had), q(it would) ],
	[ q(it'd've), q(it would have) ],
	[ q(it'll), q(it shall), q(it will) ],
	[ q(it's), q(it has), q(it is) ],
	[ q(it'sn't), q(it has not), q(it is not) ],
	[ q(let's), q(let us) ],
	[ q(ma'am), q(madam) ],
	[ q(mightn't), q(might not) ],
	[ q(mightn't've), q(might not have) ],
	[ q(might've), q(might have) ],
	[ q(mustn't), q(must not) ],
	[ q(must've), q(must have) ],
	[ q(needn't), q(need not) ],
	[ q(not've), q(not have) ],
	[ q(o'clock), q(of the clock) ],
	[ q(ol'), q(old) ],
	[ q(oughtn't), q(ought not) ],
	[ q(shan't), q(shall not) ],
	[ q(she'd), q(she had), q(she would) ],
	[ q(she'd've), q(she would have) ],
	[ q(she'll), q(she shall), q(she will) ],
	[ q(she's), q(she has), q(she is) ],
	[ q(she'sn't), q(she has not), q(she is not) ],
	[ q(should've), q(should have) ],
	[ q(shouldn't), q(should not) ],
	[ q(shouldn't've), q(should not have) ],
	[ q(somebody'd), q(somebody had), q(somebody would) ],
	[ q(somebody'd've), q(somebody would have) ],
	[ q(somebody'dn't've), q(somebody would not have) ],
	[ q(somebody'll), q(somebody shall), q(somebody will) ],
	[ q(somebody's), q(somebody has), q(somebody is) ],
	[ q(someone'd), q(someone had), q(someone would) ],
	[ q(someone'd've), q(someone would have) ],
	[ q(someone'll), q(someone shall), q(someone will) ],
	[ q(someone's), q(someone has), q(someone is) ],
	[ q(something'd), q(something had), q(something would) ],
	[ q(something'd've), q(something would have) ],
	[ q(something'll), q(something shall), q(something will) ],
	[ q(something's), q(something has), q(something is) ],
	[ q('sup), q(what is up) ],
	[ q(that'll), q(that will) ],
	[ q(that's), q(that has), q(that is) ],
	[ q(there'd), q(there had), q(there would) ],
	[ q(there'd've), q(there would have) ],
	[ q(there're), q(there are) ],
	[ q(there's), q(there has), q(there is) ],
	[ q(they'd), q(they had), q(they would) ],
	[ q(they'dn't), q(they would not) ],
	[ q(they'dn't've), q(they would not have) ],
	[ q(they'd've), q(they would have) ],
	[ q(they'd'ven't), q(they would have not) ],
	[ q(they'll), q(they shall), q(they will) ],
	[ q(they'lln't've), q(they will not have) ],
	[ q(they'll'ven't), q(they will have not) ],
	[ q(they're), q(they are) ],
	[ q(they've), q(they have) ],
	[ q(they'ven't), q(they have not) ],
	[ q('tis), q(it is) ],
	[ q('twas), q(it was) ],
	[ q(wanna), q(want to) ],
	[ q(wasn't), q(was not) ],
	[ q(we'd), q(we had), q(we would) ],
	[ q(we'd've), q(we would have) ],
	[ q(we'dn't've), q(we would not have) ],
	[ q(we'll), q(we will) ],
	[ q(we'lln't've), q(we will not have) ],
	[ q(we're), q(we are) ],
	[ q(we've), q(we have) ],
	[ q(weren't), q(were not) ],
	[ q(what'll), q(what shall), q(what will) ],
	[ q(when's), q(when has), q(when is) ],
	[ q(where'd), q(where did) ],
	[ q(where's), q(where has), q(where is), q(where does) ],
	[ q(where've), q(where have) ],
	[ q(who'd), q(who would), q(who had) ],
	[ q(who'd've), q(who would have) ],
	[ q(who'll), q(who shall), q(who will) ],
	[ q(who're), q(who are) ],
	[ q(who's), q(who has), q(who is) ],
	[ q(who've), q(who have) ],
	[ q(why'll), q(why will) ],
	[ q(why're), q(why are) ],
	[ q(why's), q(why has), q(why is) ],
	[ q(won't), q(will not) ],
	[ q(won't've), q(will not have) ],
	[ q(would've), q(would have) ],
	[ q(wouldn't), q(would not) ],
	[ q(wouldn't've), q(would not have) ],
	[ q(y'all), q(you all) ],
	[ q(y'all'd've), q(you all would have) ],
	[ q(y'all'dn't've), q(you all would not have) ],
	[ q(y'all'll), q(you all will) ],
	[ q(y'all'lln't), q(you all will not) ],
	[ q(y'all'll've), q(you all will have) ],
	[ q(y'all'll'ven't), q(you all will have not) ],
	[ q(you'd), q(you had), q(you would) ],
	[ q(you'd've), q(you would have) ],
	[ q(you'll), q(you shall), q(you will) ],
	[ q(you're), q(you are) ],
	[ q(you'ren't), q(you are not) ],
	[ q(you've), q(you have) ],
	[ q(you'ven't), q(you have not) ],
);

sub uncontract {
	my ($text, $options) = @_;
	my $random;
	if ( defined $options ) {
		$random = defined($options->{ random }) ? $options->{ random } : 0;
	}
	for my $e ( @contractions ) {
		my ($c, @rest) = @{ $e };
		while (my $match = ($text =~ m/\b((?:$c))\b/i)) {
			my $r = ( $random ) ? $rest[ rand @rest ] : $rest[0];
			if ( uc($1) eq $1 ) {
				$r = uc($r);
			} elsif ( ucfirst($1) eq $1 ) {
				$r = ucfirst($r);
			}
			$text =~ s/$1/$r/;
		}
	}

	$text;
}

1;
