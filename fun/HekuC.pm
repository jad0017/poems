package HekuC;

use strict;
use warnings;

use Data::Dumper;
use FindBin;

use lib $FindBin::Bin;
use Syllable;

sub new { bless {
	tempMapping => {},
	mapping     => {},
	starts      => [],
}}

my $fixcaps_word_re =
	qr/^ (?:GNU)
	   | (?:VCS)
	   | (?:GC)
	   | (?:C(?:\+\+)?)
	   | (?:STL)
	   | (?:I)
	$/xo;

my $fixcaps = sub {
	# $_[0] => word
	return $_[0]
		if ( $_[0] =~ m/$fixcaps_word_re/ );

	my $lc = lc $_[0];

	# No lowercase letters, e.g. if word is uppercase
	return $lc
		if ( $_[0] !~ m/[a-z]/o );

	return ucfirst( $lc )
		if ( $_[0] =~ m/^[A-Z]/o );

	$lc;
};

my $wordlist_file = sub {
	# $_[0] => filename
	open(my $fh, '<', $_[0])
		or die "Failed to open $_[0]: $!\n";

	my @words = ();
	while ( <$fh> ) {
		next if ( m/^\s*#/o );
		while ( m/([[:word:]'+-]+|[.,!?;])/go ) {
			my $t = $1;
			$t =~ s/^'//o;
			$t =~ s/'$//o;
			push @words, $fixcaps->($t);
		}
	}

	close $fh;

	@words;
};

my $wordlist_line = sub {
	# $_[0] => line

	my @words = ();
	while ( $_[0] =~ m/([[:word:]'+-]+|[.,!?;])/go ) {
		my $t = $1;
		$t =~ s/^'//o;
		$t =~ s/'$//o;
		push @words, $fixcaps->($t);
	}

	@words;
};

sub build_mapping {
	my $self = shift;
	my @words = @_;

	push @{ $self->{ starts } }, $words[0];

	my $current = $words[0];

	if ( scalar @words == 1 ) {
		$self->{ tempMapping }->{ $current } = {};
		goto equalize;
	}

	for my $i ( 1 .. $#words ) {
		next if ( $current eq $words[$i] );
		if ( exists $self->{ tempMapping }->{ $current } ) {
			$self->{ tempMapping }->{ $current }->{ $words[$i] } += 1.0;
		} else {
			$self->{ tempMapping }->{ $current } = { $words[$i] => 1.0 };
		}

		push(@{ $self->{ starts } }, $words[$i])
			if ( $current eq '.' and $words[$i] !~ m/^[.,!?;-]$/o );

		$current = $words[$i];
	}

equalize:

	my $mapping = $self->{ mapping };

	my ($first, $followset);
	while ( ($first, $followset) = each %{ $self->{ tempMapping } } ) {
		my $total = 0.0;
		$total += $_ for ( values %{ $followset } );

		$self->{ mapping }->{ $first } = {};

		my ($k, $v);
		while ( ($k, $v) = each %{ $followset } ) {
			$mapping->{ $first }->{ $k } = $v / $total;
		}
	}
}

sub next {
	my $self = $_[0];
	my $prev = $_[1];

	my $sum = 0.0;
	my $index = rand;

	return '.' if ( not defined $self->{ mapping }->{ $prev } );

	my ($k, $v);
	while ( ($k, $v) = each %{ $self->{ mapping }->{ $prev } } ) {
		$sum += $v;

		return $k if ( $sum >= $index );
	}

	'.';
}

sub init {
	my $self = $_[0];
	my $filename = $_[1];

	$self->build_mapping($wordlist_file->( $filename ));
}

sub init_line {
	my $self = $_[0];
	my $line = $_[1];

	$self->build_mapping($wordlist_line->( $line ));
}

sub reset {
	$_[0]->{ tempMapping } = {};
	$_[0]->{ mapping } = {};
	$_[0]->{ starts } = [];
}

sub init_array {
	my $self = shift;

	for my $file ( @_ ) {
		if ( substr($file, 0, 1) eq '/' ) {
			$self->init($file);
		} else {
			$self->init("$FindBin::Bin/$file");
		}
	}

	1;
}


sub init_list {
	my $self = shift;
	my $list = shift;

	return undef unless ( -f $list );

	open(my $fh, '<', $list)
		or die "Failed to open $list: $!\n";

	for my $line ( <$fh> ) {
		next if ( $line =~ m/^\s*#/o );
		chomp $line;
		if ( substr($line, 0, 1) eq '/' ) {
			$self->init($line);
		} else {
			$self->init("$FindBin::Bin/$line");
		}
	}

	close $fh;

	1;
}

sub reload_list {
	my $self = shift;
	my $list = shift;

	$self->reset;
	$self->init_list($list);
}

sub reload_array {
	my $self = shift;

	$self->reset;
	$self->init_array(@_);
}

sub GenHaiku {
	my $self = shift;

	return undef unless ( $self->{ mapping } );

	my @starts = @{ $self->{ starts } };
	my @syl_max;
	if ( @_ ) {
		@syl_max = @_;
	} else {
		@syl_max = ( 5, 7, 5 );
	}

	my $haiku = '';

	for my $i ( 0 .. $#syl_max ) {
		my $cur = $starts[ rand @starts ];
		my $sent = ucfirst $cur;

		my $syl = Syllable::Syllables($cur);
		my $tryagain = 0;

		# Add words until we hit our syllable max.
		while ( $syl < $syl_max[$i] ) {
			$cur = $self->next($cur);

			if ( $cur =~ m/^[,!?;]$/o ) {
				$sent .= $cur;
				next;
			}

			if ( $cur eq '.' ) {
				last if ( $tryagain );
				$tryagain = 1;
				next;
			}

			my $t = Syllable::Syllables($cur);
			if ( ($syl + $t) > $syl_max[$i] ) {
				last if ( $tryagain );
				$tryagain = 1;
				next;
			}

			$syl += $t;
			$sent .= " $cur";
		}

		$haiku .= ' / ' if ( $i );
		$haiku .= $sent;
	}

	$haiku;
}

1;
