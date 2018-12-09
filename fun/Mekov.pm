package Mekov;

use strict;
use warnings;

use FindBin;

sub new { bless {
	tempMapping => {},
	mapping     => {},
	starts      => [],
}}

my $fixcaps_word_re =
	qr/^ (?:I) $/xo;

my $fixcaps = sub {
	# $_[0] => word
	return $_[0]
		if ( $_[0] =~ m/$fixcaps_word_re/ );

	my $lc = lc $_[0];

	# No lowercase letters, e.g. if word is uppercase
	return $lc
		if ( $_[0] !~ m/[a-z]/o );

#	return ucfirst( $lc )
#		if ( $_[0] =~ m/^[A-Z]/o );

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
		$t =~ s/^['"]//o;
		$t =~ s/['"]$//o;
		push @words, $fixcaps->($t);
	}

	@words;
};

sub build_mapping {
	my $self = shift;
	my $len = shift;
	my @words = @_;

	push @{ $self->{ starts } }, $words[0];
	my $temp = { };

	for my $i ( 1 .. $#words - 1 ) {
		my $cur = $words[ $i ];
		my $follow = $words[$i + 1];

		unless ( defined $temp->{ $cur } ) {
			$temp->{ $cur } = { $follow => 1.0 };
		} else {
			$temp->{ $cur }->{ $follow } += 1.0;
		}

		if ( $words[$i - 1] =~ m/^[.!?]$/o and $cur !~ m/^[.,!?;]$/o ) {
			push(@{ $self->{ starts } }, $cur);
		}
	}

	my $mapping = $self->{ mapping };

	my ($first, $followset);
	while ( ($first, $followset) = each %{ $temp } ) {
		my $total = 0.0;
		$total += $_ for ( values %{ $followset } );

		$mapping->{ $first } = { };

		my ($k, $v);
		while ( ($k, $v) = each %{ $followset } ) {
			$mapping->{ $first }->{ $k } = $v / $total;
		}
	}
}

sub next {
	my $self = shift;
	my @prev = @_;

	my $sum = 0.0;
	my $ret = '';
	my $index = rand;

	my $key = join ' ', @prev;

	while ( not defined $self->{ mapping }->{ $key } ) {
		return '.' unless ( @prev );

		shift @prev;
		$key = join ' ', @prev;
	}

	my $mk = $self->{ mapping }->{ $key };

	my ($k, $v);
	while ( ($k, $v) = each %{ $mk } ) {
		$sum += $v;

		$ret = $k if ( $sum >= $index and $ret eq '' );
	}

	$ret;
}

sub genSentence {
	my $self = $_[0];
	my $len = $_[1] // 1;

	return '.' unless ( $self->{ mapping } );

	my @starts = @{ $self->{ starts } };

	my $cur = $self->{ starts }->[ rand @starts ];
	my $sent = ucfirst $cur;

	my @prev = ( $cur );

	# Add words until we hit sentence ends
	while ( $cur !~ m/^[.!?]$/ ) {
		$cur = $self->next(@prev);
		push @prev, split(/\s/, $cur);

		shift @prev if ( scalar @prev > $len );

		if ( $cur =~ m/^[.,!?;]$/o ) {
			$sent .= $cur;
			next;
		}

		$sent .= " $cur";
	}

	$sent;
}

sub genSentenceStart {
	my $self = $_[0];
	my $cur = $_[1];
	my $len = $_[2] // 1;

	return '.' unless ( $self->{ mapping } );

	$cur = $fixcaps->( $cur );

	my $sent = ucfirst $cur;
	my @prev = ( $cur );

	# Add words until we hit sentence ends
	while ( $cur !~ m/^[.!?]$/ ) {
		$cur = $self->next(@prev);
		push @prev, split(/\s/, $cur);

		shift @prev if ( scalar @prev > $len );

		if ( $cur =~ m/^[.,!?;]$/o ) {
			$sent .= $cur;
			next;
		}

		$sent .= " $cur";
	}

	$sent;
}


sub init {
	my $self = $_[0];
	my $filename = $_[1];
	my $len = $_[2] // 1;

	$self->build_mapping($len, $wordlist_file->( $filename ));
}

sub init_line {
	my $self = $_[0];
	my $line = $_[1];
	my $len = $_[2] // 1;

	$self->build_mapping($len, $wordlist_line->( $line ));
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

1;
