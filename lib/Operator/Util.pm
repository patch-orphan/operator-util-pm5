package Operator::Util;
use 5.006;
use strict;
use warnings;
use parent 'Exporter';

our $VERSION     = '0.00_1';
our @EXPORT_OK   = qw(
    reduce  reducewith
    zip     zipwith
    cross   crosswith
    hyper   hyperwith
    applyop reverseop
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

*reducewith = \&reduce;
*zipwith    = \&zip;
*crosswith  = \&cross;
*hyperwith  = \&hyper;

my %ops = (
    'prefix:++' => sub { ++$_[0] },
    'prefix:--' => sub { --$_[0] },
    'prefix:!'  => sub {  !$_[0] },
    'prefix:~'  => sub {  ~$_[0] },
    'prefix:\\' => sub {  \$_[0] },
    'prefix:+'  => sub {  +$_[0] },
    'prefix:-'  => sub {  -$_[0] },

    'postfix:++' => sub { $_[0]++ },
    'postfix:--' => sub { $_[0]-- },

    'infix:->'  => sub { my $m = $_[1]; $_[0]->$m },
    'infix:**'  => sub { $_[0] **  $_[1] },
    'infix:=~'  => sub { $_[0] =~  $_[1] },
    'infix:!~'  => sub { $_[0] !~  $_[1] },
    'infix:*'   => sub { $_[0] *   $_[1] },
    'infix:/'   => sub { $_[0] /   $_[1] },
    'infix:%'   => sub { $_[0] %   $_[1] },
    'infix:x'   => sub { $_[0] x   $_[1] },
    'infix:+'   => sub { $_[0] +   $_[1] },
    'infix:-'   => sub { $_[0] -   $_[1] },
    'infix:.'   => sub { $_[0] .   $_[1] },
    'infix:<<'  => sub { $_[0] <<  $_[1] },
    'infix:>>'  => sub { $_[0] >>  $_[1] },
    'infix:<'   => sub { $_[0] <   $_[1] },
    'infix:>'   => sub { $_[0] >   $_[1] },
    'infix:<='  => sub { $_[0] <=  $_[1] },
    'infix:>='  => sub { $_[0] >=  $_[1] },
    'infix:lt'  => sub { $_[0] lt  $_[1] },
    'infix:gt'  => sub { $_[0] gt  $_[1] },
    'infix:le'  => sub { $_[0] le  $_[1] },
    'infix:ge'  => sub { $_[0] ge  $_[1] },
    'infix:=='  => sub { $_[0] ==  $_[1] },
    'infix:!='  => sub { $_[0] !=  $_[1] },
    'infix:<=>' => sub { $_[0] <=> $_[1] },
    'infix:eq'  => sub { $_[0] eq  $_[1] },
    'infix:ne'  => sub { $_[0] ne  $_[1] },
    'infix:cmp' => sub { $_[0] cmp $_[1] },
    'infix:&'   => sub { $_[0] &   $_[1] },
    'infix:|'   => sub { $_[0] |   $_[1] },
    'infix:^'   => sub { $_[0] ^   $_[1] },
    'infix:&&'  => sub { $_[0] &&  $_[1] },
    'infix:||'  => sub { $_[0] ||  $_[1] },
    'infix:..'  => sub { $_[0] ..  $_[1] },
    'infix:...' => sub { $_[0] ... $_[1] },
    'infix:,'   => sub { $_[0] ,   $_[1] },
    'infix:=>'  => sub { $_[0] =>  $_[1] },
    'infix:and' => sub { $_[0] and $_[1] },
    'infix:or'  => sub { $_[0] or  $_[1] },
    'infix:xor' => sub { $_[0] xor $_[1] },
);

# Perl 5.10 operators
if ($] >= 5.010) {
    for my $op ('~~', '//') {
        $ops{"infix:$op"} = eval "sub { \$_[0] $op \$_[1] }";
    }
}

sub reduce {
    my ($op, @list) = @_;

    return unless exists $ops{"infix:$op"};
    return if @list < 2;

    my $result = shift @list;

    while (@list) {
        my $next = shift @list;
        $result = applyop($op, $result, $next);
    }

    return $result;
}

sub zip {
    my ($op, $lhs, $rhs) = @_;
    my ($a, $b, @results);

    while (@$lhs && @$rhs) {
        $a = shift @$lhs;
        $b = shift @$rhs;
        push @results, applyop($op, $a, $b);
    }

    return @results;
}

sub cross {
    my ($op, $lhs, $rhs) = @_;
    my ($a, $b, @results);

    for my $a (@$lhs) {
        for my $b (@$rhs) {
            push @results, applyop($op, $a, $b);
        }
    }

    return @results;
}

sub hyper {
    my ($op, $lhs, $rhs, %args) = @_;
    my $dwim_left  = $args{dwim_left};
    my $dwim_right = $args{dwim_right};
    my ($length, @results);

    if (!$dwim_left && !$dwim_right) {
        if (@$lhs != @$rhs) {
            die "Sorry, arrayrefs passed to non-dwimmy hyper() are not of same length:\n"
                . "    left:  " . @$lhs . " elements\n"
                . "    right: " . @$rhs . " elements\n";
        }
        $length = @$lhs;
    }
    elsif (!$dwim_left) {
        $length = @$lhs;
    }
    elsif (!$dwim_right) {
        $length = @$rhs;
    }
    else {
        $length = @$lhs > @$rhs ? @$lhs : @$rhs;
    }

    for my $i (0 .. $length - 1) {
        push @results, applyop($op, $lhs->[$i], $rhs->[$i]);
    }

    return @results;
}

sub applyop {
    my ($op, $a, $b) = @_;
    my ($type) = $op =~ m{^ (\w+) : }x;

    if (!$type) {
        $type = "infix";
        $op   = "infix:$op";
    }

    return unless exists $ops{$op};
    return $ops{$op}->($a, $b) if $type eq 'infix';
    return $ops{$op}->($a);
}

sub reverseop {
    my ($op, $a, $b) = @_;

    return applyop($op, $b, $a);
}

1;

__END__

=head1 NAME

Operator::Util - A selection of subroutines based on metaoperators in Perl 6

=head1 VERSION

This document describes Operator::Util version 0.00_1.

=head1 SYNOPSIS

    use Operator::Util;

=head1 DESCRIPTION

...

=head1 FUNCTIONS

The following functions are provided but are not exported by default.

=over 4

=item reduce($operator, @list)

...

=item zip($operator, $arrayref1, $arrayref2)

...

=item cross($operator, $arrayref1, $arrayref2)

...

=item hyper($operator, $arrayref3, $arrayref2 [, dwim_left => 1, dwim_right => 1 ])

...

=item applyop($operator, $operand1, $operand2)

...

=item reverseop($operator, $operand1, $operand2)

...

=back

=head1 SEE ALSO

...

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 ACKNOWLEDGEMENTS

...

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
