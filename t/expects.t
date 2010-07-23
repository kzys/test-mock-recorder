use strict;
use warnings;
use Test::More;
use Test::Double;

sub assert_mock {
    my ($double) = @_;

    my $obj1 = $double->replay;
    is($obj1->first, 1, 'replay');
    is($obj1->second, 2, 'replay');
    ok($double->verify($obj1), 'verified');

    eval {
        $double->verify_ok(
            sub {
                shift->second;
            }
        );
    };
    like(
        "$@",
        qr/^The first invocation of the mock should be "first" but called method was "second" /
    );

    eval {
        $double->verify_ok(
            sub {
                my $obj = shift;
                $obj->second;
                $obj->second;
                $obj->second;
            }
        );
    };
    like(
        "$@",
        qr/^The third invocation of the mock is "second" but not expected /
    );
}

my $d1 = Test::Double->new;
$d1->expects('first')->returns(1);
$d1->expects('second')->returns(2);
assert_mock($d1);

# short-form
my $d2 = Test::Double->new;
$d2->expects(
    first => 1,
    second => 2,
);
assert_mock($d2);

done_testing;
