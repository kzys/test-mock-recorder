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

    my $obj2 = $double->replay;
    $obj2->second;
    ok(! $double->verify($obj2), 'not verified');
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
