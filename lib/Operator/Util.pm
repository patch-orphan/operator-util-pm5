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

    for my $i (0 .. $length - 1) {
        push @results, applyop($op, $lhs->[$i], $rhs->[$i]);
    }

    return @results;
}

sub applyop {
    my ($op, $a, $b) = @_;
    my $type;

    ($op, $type) = _get_op_info($op);

    return unless $op;
    return $ops{$op}->($a, $b) if $type eq 'infix';
    return $ops{$op}->($a);
}

sub reverseop {
    my ($op, $a, $b) = @_;

    return applyop($op, $a) if $op =~ m{^ (?: pre | post ) fix : }x;
    return applyop($op, $b, $a);
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

Operator::Util - A selection of higher-order functions that take operators as arguments

=head1 VERSION

This document describes Operator::Util version 0.00_1.

=head1 SYNOPSIS

    use Operator::Util qw(
        reduce reducewith
        zip zipwith
        cross crosswith
        hyper hyperwith
        applyop reverseop
    );

=head1 WARNING

This is an early release of Operator::Util.  The interface and functionality may change in the future based on user feedback.  Please make suggestions by creating an issue at L<http://github.com/patch/operator-util-pm5/issues>.

=head1 DESCRIPTION

A pragmatic approach at providing the functionality of many of Perl 6's meta operators in Perl 5.

The terms "operator string" or "opstring" are used to describe a string that represents an operator, such as the string C<'+'> for the addition operator or the string C<'.'> for the concatenation operator.  Except where noted, opstrings default to binary infix operators and the short form may be used, e.g., C<'*'> instead of C<'infix:*'>.  Unary opstrings must be stated in the full form with C<prefix:> or C<postfix:> prepended.  Note however that the provided functions do not modify the operand arguments, therefore rendering C<'postfix:++'> and C<'postfix:--'> as no-ops.

When a list is passed as an argument for any of the functions, it must be either an array reference or a scalar value that will be used as a single-element list.

The following functions are provided but are not exported by default.

=over 4

=item reduce OPSTRING, LIST [, triangle => 1 ]

C<reducewith> is an alias for C<reduce>.  It may be desirable to use C<reducewith> to avoid naming conflicts or confusion with L<List::Util/reduce>.

=item zip OPSTRING, LIST1, LIST2

=item zip LIST1, LIST2

C<zipwith> is an alias for C<reduce>.

=item cross OPSTRING, LIST1, LIST2

=item cross LIST1, LIST2

C<crosswith> is an alias for C<reduce>.

=item hyper OPSTRING, LIST1, LIST2 [, dwim_left => 1, dwim_right => 1 ]

=item hyper OPSTRING, LIST

C<hyperwith> is an alias for C<reduce>.

=item applyop OPSTRING, OPERAND1, OPERAND2

=item applyop OPSTRING, OPERAND

If three arguments are provided to C<applyop>, apply the binary operator OPSTRING to the aperands OPERAND1 and OPERAND2.  If two arguments are provided, apply the unary operator OPSTRING to the aperand OPERAND.  The unary form defaults to using prefix operators, so 'prefix:' may be omitted, e.g., C<'++'> instead of C<'prefix:++'>;

    applyop '.', 'foo', 'bar'  # foobar
    applyop '++', 5            # 6

=item reverseop OPSTRING, OPERAND1, OPERAND2

C<reverseop> provides the same functionality as C<applyop> except that OPERAND1 and OPERAND2 are reversed.

    reverseop '.', 'foo', 'bar'  # barfoo

If an unary opstring is used, C<reverseop> has the same functionality as C<applyop>.

=back

The optional named-argument C<flat> can be passed to C<reduce>, C<zip>, C<cross>, and C<hyper>.  It defaults to C<1>, which causes the function to return a flat list.  When set to C<0>, it causes the return value from each operator to be stored in an array ref, resulting in a "list of lists" being returned from the function. 

    zip [1..3], ['a'..'c']             # 1, 'a', 2, 'b', 3, 'c'
    zip [1..3], ['a'..'c'], flat => 0  # [1, 'a'], [2, 'b'], [3, 'c']

=head1 TODO

=over

=item * Add C<warn>ings on errors instead of simply C<return>ing

=item * Add named unary operators such as C<uc> and C<lc>

=item * Allow unlimited arrayrefs passed to C<zip>, C<cross>, and C<hyper> instead of just two

=item * Support meta-operator literals such as C<Z> and C<X>

=item * Should the first argument optionally be a subroutine ref instead of an operator string?

=item * Should the C<flat =E<gt> 0> option be changed to C<lol =E<gt> 1>?

=item * Convert tests to L<TestML>

=back

=head1 SEE ALSO

=over

=item * L<List::MoreUtils/pairwise> is simular to C<zip> except that its first argument is a block instead of an operator string and the remaining arguments are arrays instead of array refs:

    pairwise { $a + $b }, @array1, @array2  # List::MoreUtils
    zip '+', \@array1, \@array2             # Operator::Util

=item * C<mesh> a.k.a. L<List::MoreUtils/zip> is simular to C<zip> when using the default operator C<','> except that the arguments are arrays instead of array refs:

    mesh @array1, @array2   # List::MoreUtils
    zip \@array1, \@array2  # Operator::Util

=item * L<Set::CrossProduct> is an object-oriented alternative to C<cross> when using the default operator C<,>

=item * The "Meta operators" section of Synopsis 3: Perl 6 Operators (L<http://perlcabal.org/syn/S03.html#Meta_operators>) is the inspiration for this module

=back

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 ACKNOWLEDGEMENTS

=over

=item * This module is based on the Perl 6 specification, as described in the Synopsis and implemented in Rakudo

=item * Much of the documentation is based on Synopsis 3: Perl 6 Operators (L<http://perlcabal.org/syn/S03.html>)

=item * Most of the tests were forked from the Official Perl 6 Test Suite (L<https://github.com/perl6/roast>)

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010, 2011 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
