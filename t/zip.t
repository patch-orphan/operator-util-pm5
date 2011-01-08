use Test::More tests => 9;

use ok 'Operator::Util', qw( zip );

is_deeply [zip(['a','b'], [1,2])], ['a',1,'b',2], 'zip() produces expected result';

is_deeply [zip('**', [1,2,3], [2,4])], [1,16], 'zip(**) works';

is_deeply [zip('.', ['a','b'], [1,2])], ['a1','b2'], 'zip(.) produces expected result';

is_deeply [zip('*', [1,2], [3,4])], [3,8], 'zip(*) works';

is_deeply [zip('<=>', [1,2], [3,2,0])], [-1, 0], 'zip(<=>) works';

# tests for non-list arguments
is_deeply [zip('*', 1, [3,4])], [3], 'zip(*) works with scalar left side';
is_deeply [zip('*', [1,2], 3)], [3], 'zip(*) works with scalar right side';
is_deeply [zip('*', 1, 3)], [3], 'zip(*) works with scalar both sides';
