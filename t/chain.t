use strict;
use warnings;
use Test::More;

use_ok 'Test::Mock::Record';

my $len = length 'hello world';

my $double = Test::Mock::Record->new;
$double->expects('print')->with('hello world')->returns($len);

my $io = $double->replay;
is($io->print('hello world'), $len);

$double->verify($io);

done_testing;
