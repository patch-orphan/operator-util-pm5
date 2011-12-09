use strict;
use warnings;
use Test::More;

eval 'use Test::Spelling';
plan skip_all => 'Test::Spelling not installed; skipping' if $@;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__DATA__
applyop
arrayrefs
circumfix
crosswith
dwim
dwimmery
dwimminess
dwimmy
hypers
infixes
multi
opstring
OPSTRING
opstrings
Opstrings
postcircumfix
postfix
Rakudo
reverseop
TODO
unary
Unary
utils
zipwith
