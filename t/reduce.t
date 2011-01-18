use Test::More tests => 93;

use ok 'Operator::Util', qw( reduce );

# [...] reduce metaoperator
{
    my @array = (5, -3, 7, 0, 1, -9);
    my $sum   = 5 + -3 + 7 + 0 + 1 + -9; # laziness :)

    is reduce('+',   \@array ), $sum,           'reduce(+) works';
    is reduce('*',   [1,2,3] ), 1*2*3,          'reduce(*) works';
    is reduce('-',   [1,2,3] ), 1-2-3,          'reduce(-) works';
    is reduce('/',   [12,4,3]), 12/4/3,         'reduce(/) works';
    is reduce('div', [12,4,3]), 12 div 4 div 3, 'reduce(div) works';
    is reduce('**',  [2,2,3] ), 2**2**3,        'reduce(**) works';
    is reduce('%',   [13,7,4]), 13%7%4,         'reduce(%) works';
    is reduce('mod', [13,7,4]), 13 mod 7 mod 4, 'reduce(mod) works';

    is_deeply [reduce '+', \@array, triangle=>1], [5,2,9,9,10,1], 'triangle reduce(+) works';
    is_deeply [reduce '-', [1,2,3], triangle=>1], [1,-1,-4],      'triangle reduce(-) works';
}

{
    is reduce('~', [qw<a b c d>]), 'abcd', 'reduce(.) works';
    is_deeply [reduce '~', [qw<a b c d>], triangle=>1], [qw<a ab abc abcd>], 'triangle reduce(.) works';
}

{
    ok  reduce('<',  ['1,2,3,4']), 'reduce(<) works (1)';
    ok !reduce('<',  ['1,3,2,4']), 'reduce(<) works (2)';
    ok  reduce('>',  ['4,3,2,1']), 'reduce(>) works (1)';
    ok !reduce('>',  ['4,2,3,1']), 'reduce(>) works (2)';
    ok  reduce('==', ['4,4,4']  ), 'reduce(==) works (1)';
    ok !reduce('==', ['4,5,4']  ), 'reduce(==) works (2)';
    ok  reduce('!=', ['4,5,6']  ), 'reduce(!=) works (1)';
    ok !reduce('!=', ['4,4,4']  ), 'reduce(!=) works (2)';
}

{
    ok !reduce('eq', [qw<a a b a>]), 'reduce(eq) basic sanity (positive)';
    ok  reduce('eq', [qw<a a a a>]), 'reduce(eq) basic sanity (negative)';
    ok  reduce('ne', [qw<a b c a>]), 'reduce(ne) basic sanity (positive)';
    ok !reduce('ne', [qw<a a b c>]), 'reduce(ne) basic sanity (negative)';
    ok  reduce('lt', [qw<a b c e>]), 'reduce(lt) basic sanity (positive)';
    ok !reduce('lt', [qw<a a c e>]), 'reduce(lt) basic sanity (negative)';
}

{
    my $a = 1;
    my $b = 2;

    ok  reduce('==', [1,1,1,1]), 'reduce(==) with literals';
    ok  reduce('==', [$a,$a,$a]), 'reduce(==) with vars (positive)';
    ok !reduce('==', [$a,$a,2]),  'reduce(==) with vars (negative)';
    ok  reduce('!=', [$a,$b,$a]), 'reduce(!=) basic sanity (positive)';
    ok !reduce('!=', [$a,$b,$b]), 'reduce(!=) basic sanity (negative)';
}

{
    is [reduce '<', [1,2,3,4], triangle=>1], [1,1,1,1], 'triangle reduce(<) works (1)';
    is [reduce '<', [1,3,2,4], triangle=>1], [1,1,0,0], 'triangle reduce(<) works (2)';
    is [reduce '>', [4,3,2,1], triangle=>1], [1,1,1,1], 'triangle reduce(>) works (1)';
    is [reduce '>', [4,2,3,1], triangle=>1], [1,1,0,0], 'triangle reduce(>) works (2)';
    is [reduce '==', [4,4,4],  triangle=>1], [1,1,1],   'triangle reduce(==) works (1)';
    is [reduce '==', [4,5,4],  triangle=>1], [1,0,0],   'triangle reduce(==) works (2)';
    is [reduce '!=', [4,5,6],  triangle=>1], [1,1,1],   'triangle reduce(!=) works (1)';
    is [reduce '!=', [4,5,5],  triangle=>1], [1,1,0],   'triangle reduce(!=) works (2)';
    is [reduce '**', [1,2,3],  triangle=>1], [3,8,1],   'triangle reduce(**) (right assoc) works (1)';
    is [reduce '**', [3,2,0],  triangle=>1], [0,1,3],   'triangle reduce(**) (right assoc) works (2)';
}

{
    my @array = (undef, undef, 3, undef, 5);
    is reduce('||', \@array), 3, 'reduce(||) works';
    is reduce('or', \@array), 3, 'reduce(or) works';
}

{
    my @array = (undef, undef, 0, 3, undef, 5);
    is reduce('||', \@array), 3, 'reduce(||) works';
    is reduce('or', \@array), 3, 'reduce(or) works';

    # undef as well as [//] should work too, but testing it like
    # this would presumably emit warnings when we have them.
    is [reduce '||', [0,0,3,4,5], triangle=>1], [0,0,3,3,3], 'triangle reduce(||) works';
}

{
    my @array = (undef, undef, 0, 3, undef, 5);
    my @array1 = (2, 3, 4);
    ok !reduce('&&', \@array), "reduce(&&) works with 1 false";
    is reduce('&&' \@array1), 4, "reduce(&&) works";
    ok !reduce('and', \@array), "reduce(and) works with 1 false";
    is reduce('and', \@array1), 4, "reduce(and) works";
}

# not currently legal without an infix subscript operator
#{
#    my $hash = {a => {b => {c => {d => 42, e => 23}}}};
#    is try { [%{}] $hash, <a b c d> }, 42, '[.{}] works';
#}
 
#{
#    my $hash = {a => {b => 42}};
#    is ([%{}] $hash, <a b>), 42, '[.{}] works two levels deep';
#}
 
#{
#    my $arr = [[[1,2,3],[4,5,6]],[[7,8,9],[10,11,12]]];
#    is ([@{}] $arr, 1, 0, 2), 9, '[.[]] works';
#}

{
    my @array = (5,-3,7,0,1,-9);
    # according to http://irclog.perlgeek.de/perl6/2008-09-10#i_560910
    # [,] returns a scalar (holding an Array)
    my $count = 0;
    $count++ for reduce ',', \@array;
    is $count, 6, 'reduce(,) returns a list';
}

# {
#   my $arr = [ 42, [ 23 ] ];
#   $arr[1][1] = $arr;
# 
#   is try { [.[]] $arr, 1, 1, 1, 1, 1, 0 }, 23, '[.[]] works with infinite data structures';
# }
# 
# {
#   my $hash = {a => {b => 42}};
#   $hash<a><c> = $hash;
# 
#   is try { [.{}] $hash, <a c a c a b> }, 42, '[.{}] works with infinite data structures';
# }

# L<S03/"Reduction operators"/"Among the builtin operators, [+]() returns 0 and [*]() returns 1">

is reduce('*'), 1, 'reduce(*) with no operands returns 1';
is reduce('+'), 0, 'reduce(+) with no operands returns 0';

is reduce('*', 41), 41, 'reduce(*, 41) returns 41';
is reduce('*', 42), 42, 'reduce(*, 42) returns 42';
is reduce('*', 42, triangle=>1), 42, 'triangle reduce(*, 42) returns 42';
is reduce('~', 'towel'), 'towel', 'reduce(~, "towel") returns "towel"';
is reduce('~,', 'washcloth'), 'washcloth', 'reduce(~, "washcloth") returns "washcloth"';
is reduce('~', 'towel', triangle=>1), 'towel', "triangle reduce(~, 'towel') returns 'towel'");
is reduce('<', 42), 1, 'reduce(<, 42) returns true');
is reduce('<', 42, triangle=>1), 1, 'triangle reduce(<, 42) returns true');

is reduce([\*] 1..*).[^10].join(', '), '1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800', 
    'triangle reduce is lazy');
is reduce([\R~] 'a'..*).[^8].join(', '), 'a, ba, cba, dcba, edcba, fedcba, gfedcba, hgfedcba',
    'triangle reduce is lazy');

# RT #65164 (TODO: implement [^^])
#?rakudo skip 'implement [^^]'
{
    is [^^](0, 42), 42, '[^^] works (one of two true)';
    is [^^](42, 0), 42, '[^^] works (one of two true)';
    ok ! [^^](1, 42),   '[^^] works (two true)';
    ok ! [^^](0, 0),    '[^^] works (two false)';

    ok ! [^^](0, 0, 0), '[^^] works (three false)';
    ok ! [^^](5, 9, 17), '[^^] works (three true)';

    is [^^](5, 9, 0),  (5 ^^ 9 ^^ 0),  '[^^] mix 1';
    is [^^](5, 0, 17), (5 ^^ 0 ^^ 17), '[^^] mix 2';
    is [^^](0, 9, 17), (0 ^^ 9 ^^ 17), '[^^] mix 3';
    is [^^](5, 0, 0),  (5 ^^ 0 ^^ 0),  '[^^] mix 4';
    is [^^](0, 9, 0),  (0 ^^ 9 ^^ 0),  '[^^] mix 5';
    is [^^](0, 0, 17), (0 ^^ 0 ^^ 17), '[^^] mix 6';
}

# RT #75234
# rakudo had a problem where once-used meta operators weren't installed
# in a sufficiently global location, so using a meta operator in class once
# makes it unusable further on
{
    class A {
        method m { return [~] gather for ^3 {take 'a'} }
    }
    class B {
        method n { return [~] gather for ^4 {take 'b'}}
    }
    is A.new.m, 'aaa',  '[~] works in first class';
    is B.new.n, 'bbbb', '[~] works in second class';
    is ([~] 1, 2, 5), '125', '[~] works outside class';
}
