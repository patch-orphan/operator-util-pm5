use Test::More tests => 9;

use ok 'Operator::Util', qw( zip );

is_deeply [zip(['a','b'], [1,2])], ['a',1,'b',2], 'zip() produces expected result';

is_deeply [zip('**', [1,2,3], [2,4])], [1,16], 'zip(**) works';

is_deeply [zip('.', ['a','b'], [1,2])], ['a1','b2'], 'zip(.) produces expected result';

is_deeply [zip('*', [1,2], [3,4])], [3,8], 'zip(*) works';

is_deeply [zip('<=>', [1,2], [3,2,0])], [-1, 0], 'zip(<=>) works';

# tests for laziness
#is_deeply zip(1..* Z** 1..*).[^5], (1**1, 2**2, 3**3, 4**4, 5**5), 'zip-power with lazy lists';
#is_deeply zip(1..* Z+ (3, 2 ... *)).[^5], (1+3, 2+2, 3+1, 4+0, 5-1), 'zip-plus with lazy lists';

# tests for non-list arguments
is_deeply [zip('*', 1, [3,4])], [3], 'zip(*) works with scalar left side';
is_deeply [zip('*', [1,2], 3)], [3], 'zip(*) works with scalar right side';
is_deeply [zip('*', 1, 3)], [3], 'zip(*) works with scalar both sides';

# L<S03/"Hyper operators"/is assumed to be infinitely extensible>

#is_deeply zip(<a b c d> Z 'x', 'z', *), <a x b z c z d z>, 'non-meta zip extends right argument ending with *';
#is_deeply zip(1, 2, 3, * Z 10, 20, 30, 40, 50),
#    (1, 10, 2, 20, 3, 30, 3, 40, 3, 50), 'non-meta zip extends left argument ending with *';
#is_deeply zip(2, 10, * Z 3, 4, 5, *).munch(10),
#    (2, 3, 10, 4, 10, 5, 10, 5, 10, 5),
#    'non-meta zip extends two arguments ending with *';
#
#is_deeply zip(<a b c d> Z~ 'x', 'z', *), <ax bz cz dz>, 'zip-concat extends right argument ending with *';
#is_deeply zip(1, 2, 3, * Z+ 10, 20, 30, 40, 50), (11, 22, 33, 43, 53), 'zip-plus extends left argument ending with *';
#is_deeply zip(2, 10, * Z* 3, 4, 5, *).munch(5),
#    (6, 40, 50, 50, 50), 'zip-product extends two arguments ending with *';
