use strict;
use warnings;
use Test::More;

use_ok 'Test::Double';

my $double = Test::Double->new;
$double->expects('print')->with('hello');

# callback
$double->verify_ok(
    sub {
        shift->print('hello');
    }
);

# non-callback
my $io = $double->replay;
$io->print('hello');
$double->verify_ok($io);

done_testing;
