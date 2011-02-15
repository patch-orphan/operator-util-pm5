package Operator::Util;
use 5.006;
use strict;
use warnings;
use parent 'Exporter';

our $VERSION     = '0.01_1';
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
    # binary infix
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
    'infix:='   => sub { $_[0] =   $_[1] },
    'infix:**=' => sub { $_[0] **= $_[1] },
    'infix:*='  => sub { $_[0] *=  $_[1] },
    'infix:/='  => sub { $_[0] /=  $_[1] },
    'infix:%='  => sub { $_[0] %=  $_[1] },
    'infix:x='  => sub { $_[0] x=  $_[1] },
    'infix:+='  => sub { $_[0] +=  $_[1] },
    'infix:-='  => sub { $_[0] -=  $_[1] },
    'infix:.='  => sub { $_[0] .=  $_[1] },
    'infix:<<=' => sub { $_[0] <<= $_[1] },
    'infix:>>=' => sub { $_[0] >>= $_[1] },
    'infix:&='  => sub { $_[0] &=  $_[1] },
    'infix:|='  => sub { $_[0] |=  $_[1] },
    'infix:^='  => sub { $_[0] ^=  $_[1] },
    'infix:&&=' => sub { $_[0] &&= $_[1] },
    'infix:||=' => sub { $_[0] ||= $_[1] },
    'infix:,'   => sub { $_[0] ,   $_[1] },
    'infix:=>'  => sub { $_[0] =>  $_[1] },
    'infix:and' => sub { $_[0] and $_[1] },
    'infix:or'  => sub { $_[0] or  $_[1] },
    'infix:xor' => sub { $_[0] xor $_[1] },
    'infix:->'  => sub { my $m = $_[1];         $_[0]->$m },
    'infix:->=' => sub { my $m = $_[1]; $_[0] = $_[0]->$m },

    # unary prefix
    'prefix:++' => sub { ++$_[0]  },
    'prefix:--' => sub { --$_[0]  },
    'prefix:!'  => sub {  !$_[0]  },
    'prefix:~'  => sub {  ~$_[0]  },
    'prefix:\\' => sub {  \$_[0]  },
    'prefix:+'  => sub {  +$_[0]  },
    'prefix:-'  => sub {  -$_[0]  },
    'prefix:$'  => sub { ${$_[0]} },
    'prefix:@'  => sub { @{$_[0]} },
    'prefix:%'  => sub { %{$_[0]} },
    'prefix:&'  => sub { &{$_[0]} },
    'prefix:*'  => sub { *{$_[0]} },

    # unary postfix
    'postfix:++' => sub { $_[0]++ },
    'postfix:--' => sub { $_[0]-- },

    # circumfix
    'circumfix:()'  => sub {  ($_[0]) },
    'circumfix:[]'  => sub {  [$_[0]] },
    'circumfix:{}'  => sub {  {$_[0]} },
    'circumfix:${}' => sub { ${$_[0]} },
    'circumfix:@{}' => sub { @{$_[0]} },
    'circumfix:%{}' => sub { %{$_[0]} },
    'circumfix:&{}' => sub { &{$_[0]} },
    'circumfix:*{}' => sub { *{$_[0]} },

    # postcircumfix
    'postcircumfix:[]'   => sub { $_[0]->[$_[1]] },
    'postcircumfix:{}'   => sub { $_[0]->{$_[1]} },
    'postcircumfix:->[]' => sub { $_[0]->[$_[1]] },
    'postcircumfix:->{}' => sub { $_[0]->{$_[1]} },
);

my %rightops = ('infix:**' => 1);
my %chainops = map { ( "infix:$_" => 1 ) } qw{
    < > <= >= lt gt le ge == != <=> eq ne cmp ~~
};

# Perl 5.10 operators
if ($] >= 5.010) {
    for my $op ('~~', '//') {
        $ops{"infix:$op"} = eval "sub { \$_[0] $op \$_[1] }";
    }
}

sub reduce {
    my ($op, $list, %args) = @_;
    my ($type, $trait);

    my @list = ref $list eq 'ARRAY' ? @$list : $list;

    return unless @list;
    return $list[0] if @list == 1;

    ($op, $type, $trait) = _get_op_info($op);

    return unless $op;
    return if $type ne 'infix';

    if ($trait eq 'right') {
        @list = reverse @list;
    }

    my $result   = shift @list;
    my $bool     = 1;
    my @triangle = $trait eq 'chain' ? $bool : $result;

    my $apply = sub {
        my ($a, $b) = @_;
        return applyop( $op, $trait eq 'right' ? ($b, $a) : ($a, $b) );
    };

    while (@list) {
        my $next = shift @list;

        if ($trait eq 'chain') {
            $bool = $bool && $apply->($result, $next);
            $result = $next;
            push @triangle, $bool if $args{triangle};
        }
        else {
            $result = $apply->($result, $next);
            push @triangle, $result if $args{triangle};
        }
    }

    return @triangle if $args{triangle};
    return $bool     if $trait eq 'chain';
    return $result;
}

sub zip {
    my $op = @_ == 2 ? 'infix:,' : shift;
    my ($lhs, $rhs) = @_;
    my ($a, $b, @results);

    $lhs = [$lhs] if ref $lhs ne 'ARRAY';
    $rhs = [$rhs] if ref $rhs ne 'ARRAY';

    while (@$lhs && @$rhs) {
        $a = shift @$lhs;
        $b = shift @$rhs;
        push @results, applyop($op, $a, $b);
    }

    return @results;
}

sub cross {
    my $op = @_ == 2 ? 'infix:,' : shift;
    my ($lhs, $rhs) = @_;
    my ($a, $b, @results);

    $lhs = [$lhs] if ref $lhs ne 'ARRAY';
    $rhs = [$rhs] if ref $rhs ne 'ARRAY';

    for my $a (@$lhs) {
        for my $b (@$rhs) {
            push @results, applyop($op, $a, $b);
        }
    }

    return @results;
}

sub hyper {
    my ($op, $lhs, $rhs, %args) = @_;

    if (@_ == 2) {
        return map { applyop($op, $_) } @$lhs
            if ref $lhs eq 'ARRAY';
        return map { $_ => applyop($op, $lhs->{$_}) } keys %$lhs
            if ref $lhs eq 'HASH';
        return applyop($op, $$lhs)
            if ref $lhs eq 'SCALAR';
        return applyop($op, $lhs);
    }

    my $dwim_left  = $args{dwim_left}  || $args{dwim};
    my $dwim_right = $args{dwim_right} || $args{dwim};
    my ($length, @results);

    $lhs = [$lhs] if ref $lhs ne 'ARRAY';
    $rhs = [$rhs] if ref $rhs ne 'ARRAY';

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

    my $lhs_index = 0;
    my $rhs_index = 0;
    for (1 .. $length) {
        $lhs_index = 0 if $dwim_left  && $lhs_index > $#{$lhs};
        $rhs_index = 0 if $dwim_right && $rhs_index > $#{$rhs};
        push @results, applyop($op, $lhs->[$lhs_index], $rhs->[$rhs_index]);
    }
    continue {
        $lhs_index++;
        $rhs_index++;
    }

    return @results;
}

sub applyop {
    my ($op) = @_;
    my $type;
    ($op, $type) = _get_op_info($op);

    return unless $op;
    return $ops{$op}->( @_[1, 2] )
        if $type eq 'infix'
        || $type eq 'postcircumfix';
    return $ops{$op}->( $_[1] );
}

sub reverseop {
    my ($op) = @_;

    return applyop( $op, $_[1]    ) if $op =~ m{^ (?: pre | post ) fix : }x;
    return applyop( $op, @_[1, 2] );
}

sub _get_op_info {
    my ($op) = @_;
    my ($type) = $op =~ m{^ (\w+) : }x;

    if (!$type) {
        $type = "infix";
        $op   = "infix:$op";
    }

    my $trait = $chainops{$op} ? 'chain' :
                $rightops{$op} ? 'right' :
                                 ''      ;

    return unless exists $ops{$op};
    return $op, $type, $trait;
}

1;

__END__

=head1 NAME

Operator::Util - A selection of array and hash functions that extend operators

=head1 VERSION

This document describes Operator::Util version 0.01_1.

=head1 SYNOPSIS

    use Operator::Util qw(
        reduce reducewith
        zip zipwith
        cross crosswith
        hyper hyperwith
        applyop reverseop
    );

=head1 WARNING

This is an early release of Operator::Util.  The interface and functionality
may change in the future based on user feedback.  Please make suggestions by
creating an issue at L<http://github.com/patch/operator-util-pm5/issues>.

The documentation is in the process of being thoroughly expanded.

=head1 DESCRIPTION

A pragmatic approach at providing the functionality of many of Perl 6's meta
operators in Perl 5.

The terms "operator string" or "opstring" are used to describe a string that
represents an operator, such as the string C<'+'> for the addition operator or
the string C<'.'> for the concatenation operator.  Except where noted,
opstrings default to binary infix operators and the short form may be used,
e.g., C<'*'> instead of C<'infix:*'>.  All other operator types (prefix,
postfix, circumfix, and postcircumfix) must have the type prepended in the
opstrings, e.g., C<prefix:++> and C<postcircumfix:{}>.

When a list is passed as an argument for any of the functions, it must be
either an array reference or a scalar value that will be used as a
single-element list.

The following functions are provided but are not exported by default.

=over 4

=head2 Reduction

=item reduce OPSTRING, LIST [, triangle => 1 ]

C<reducewith> is an alias for C<reduce>.  It may be desirable to use
C<reducewith> to avoid naming conflicts or confusion with
L<List::Util/reduce>.

Any infix opstring (except for non-associating operators) can be passed to
C<reduce> along with an arreyref to reduce the array using that operation:

    reduce('+', [1, 2, 3]);  # 1 + 2 + 3 = 6
    my @a = (5, 6);
    reduce('*', \@a);        # 5 * 6 = 30

C<reduce> associates the same way as the operator used:

    reduce('-', [4, 3, 2]);   # 4-3-2 = (4-3)-2 = -1
    reduce('**', [4, 3, 2]);  # 4**3**2 = 4**(3**2) = 262144

For comparison operators (like C<<>), all reduced pairs of operands are broken
out into groups and joined with C<&&> because Perl 5 doesn't support
comparison operator chaining:

    reduce('<', [1, 3, 5]);  # 1 < 3 && 3 < 5

If fewer than two elements are given, the results will vary depending on the
operator:

    reduce('+', []);   # 0
    reduce('+', [5]);  # 5
    reduce('*', []);   # 1
    reduce('*', [5]);  # 5

If there is one element, the C<reduce> returns that one element.  However,
this default doesn't make sense for operators like C<<> that don't return
the same type as they take, so these kinds of operators overload the
single-element case to return something more meaningful.

You can also reduce the comma operator, although there isn't much point in
doing so.  This just returns an arreyref that compares deeply to the arreyref
passed in:

    [1, 2, 3]
    reduce(',', [1, 2, 3])  # same thing

Operators with zero-element arrayrefs return the following values:

    **    # 1    (arguably nonsensical)
    =~    # 1    (also for 1 arg)
    !~    # 1    (also for 1 arg)
    *     # 1
    /     # fail (reduce is nonsensical)
    %     # fail (reduce is nonsensical)
    x     # fail (reduce is nonsensical)
    +     # 0
    -     # 0
    .     # ''
    <<    # fail (reduce is nonsensical)
    >>    # fail (reduce is nonsensical)
    <     # 1    (also for 1 arg)
    >     # 1    (also for 1 arg)
    <=    # 1    (also for 1 arg)
    >=    # 1    (also for 1 arg)
    lt    # 1    (also for 1 arg)
    le    # 1    (also for 1 arg)
    gt    # 1    (also for 1 arg)
    ge    # 1    (also for 1 arg)
    ==    # 1    (also for 1 arg)
    !=    # 1    (also for 1 arg)
    eq    # 1    (also for 1 arg)
    ne    # 1    (also for 1 arg)
    ~~    # 1    (also for 1 arg)
    &     # -1   (from ^0, the 2's complement in arbitrary precision)
    |     # 0
    &&    # 1
    ||    # 0
    //    # 0
    =     # undef (same for all assignment operators)
    ,     # []

You can say

    reduce('||', [a(), b(), c(), d()]);

to return the first true result, but the evaluation of the list is controlled
by the semantics of the list, not the semantics of C<||>.

To generate all intermediate results along with the final result, you can set
the C<triangle> argument:

    reduce('+', [1..5], triangle=>1);  # (1, 3, 6, 10, 15)

The visual picture of a triangle is not accidental.  To produce a triangular
list of lists, you can use a "triangular comma":

    reduce(',', [1..5], triangle=>1);
    # [1],
    # [1,2],
    # [1,2,3],
    # [1,2,3,4],
    # [1,2,3,4,5]

=head2 Zip

=item zip OPSTRING, LIST1, LIST2

=item zip LIST1, LIST2

C<zipwith> is an alias for C<zip>.

=head2 Cross

=item cross OPSTRING, LIST1, LIST2

=item cross LIST1, LIST2

C<crosswith> is an alias for C<cross>.

=head2 Hyper

=item hyper OPSTRING, LIST1, LIST2 [, dwim_left => 1, dwim_right => 1 ]

=item hyper OPSTRING, LIST

C<hyperwith> is an alias for C<hyper>.

=head2 Other utils

=item applyop OPSTRING, OPERAND1, OPERAND2

=item applyop OPSTRING, OPERAND

If three arguments are provided to C<applyop>, apply the binary operator
OPSTRING to the operands OPERAND1 and OPERAND2.  If two arguments are
provided, apply the unary operator OPSTRING to the operand OPERAND.  The unary
form defaults to using prefix operators, so 'prefix:' may be omitted, e.g.,
C<'++'> instead of C<'prefix:++'>;

    applyop '.', 'foo', 'bar'  # foobar
    applyop '++', 5            # 6

=item reverseop OPSTRING, OPERAND1, OPERAND2

C<reverseop> provides the same functionality as C<applyop> except that
OPERAND1 and OPERAND2 are reversed.

    reverseop '.', 'foo', 'bar'  # barfoo

If an unary opstring is used, C<reverseop> has the same functionality as
C<applyop>.

=back

The optional named-argument C<flat> can be passed to C<reduce>, C<zip>,
C<cross>, and C<hyper>.  It defaults to C<1>, which causes the function to
return a flat list.  When set to C<0>, it causes the return value from each
operator to be stored in an array ref, resulting in a "list of lists" being
returned from the function.

    zip [1..3], ['a'..'c']             # 1, 'a', 2, 'b', 3, 'c'
    zip [1..3], ['a'..'c'], flat => 0  # [1, 'a'], [2, 'b'], [3, 'c']

=head1 TODO

=over

=item * Add C<warn>ings on errors instead of simply C<return>ing

=item * Add named unary operators such as C<uc> and C<lc>

=item * Allow unlimited arrayrefs passed to C<zip>, C<cross>, and C<hyper>
instead of just two

=item * Support meta-operator literals such as C<Z> and C<X>

=item * Should the first argument optionally be a subroutine ref instead of an
operator string?

=item * Should the C<flat =E<gt> 0> option be changed to C<lol =E<gt> 1>?

=item * Convert tests to L<TestML>

=back

=head1 SEE ALSO

=over

=item * L<perlop>

=item * L<List::MoreUtils/pairwise> is similar to C<zip> except that its first
argument is a block instead of an operator string and the remaining arguments
are arrays instead of array refs:

    pairwise { $a + $b }, @array1, @array2  # List::MoreUtils
    zip '+', \@array1, \@array2             # Operator::Util

=item * C<mesh> a.k.a. L<List::MoreUtils/zip> is similar to C<zip> when using
the default operator C<','> except that the arguments are arrays instead of
array refs:

    mesh @array1, @array2   # List::MoreUtils
    zip \@array1, \@array2  # Operator::Util

=item * L<Set::CrossProduct> is an object-oriented alternative to C<cross>
when using the default operator C<,>

=item * The "Meta operators" section of Synopsis 3: Perl 6 Operators
(L<http://perlcabal.org/syn/S03.html#Meta_operators>) is the inspiration for
this module

=back

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 ACKNOWLEDGEMENTS

=over

=item * This module is loosely based on the Perl 6 specification, as described
in the Synopsis and implemented in Rakudo

=item * Much of the documentation is based on Synopsis 3: Perl 6 Operators
(L<http://perlcabal.org/syn/S03.html>)

=item * Most of the tests were forked from the Official Perl 6 Test Suite
(L<https://github.com/perl6/roast>)

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010, 2011 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
