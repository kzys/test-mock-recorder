use strict;
use warnings;
use Test::More;

use_ok 'Test::Double';
my $double = Test::Double->new;
$double->expects('print');
isnt($double->replay, $double->replay);

eval {
    $double->replay(
        sub {
            ;
        }
    );
};
ok($@, 'expected but not called');

ok(
    $double->replay(
        sub {
            shift->print('hello world');
        }
    )
);

done_testing;
