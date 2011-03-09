use strict;
use warnings;
use Test::More;

use_ok 'Test::Mock::Record';
my $double = Test::Mock::Record->new;
$double->expects('print');
isnt($double->replay, $double->replay);

eval {
    $double->replay(
        sub {
            ;
        }
    );
};
like("$@", qr/The first invocation of the mock is "print" but not called /);

ok(
    $double->replay(
        sub {
            shift->print('hello world');
        }
    )
);

done_testing;
