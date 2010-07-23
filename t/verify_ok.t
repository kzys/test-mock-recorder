use strict;
use warnings;
use Test::More tests => 2;

use_ok 'Test::Double';

my $double = Test::Double->new;
$double->expects('print')->with(['hello']);

$double->verify_ok(
    sub {
        shift->print('hello');
    }
);

done_testing;
