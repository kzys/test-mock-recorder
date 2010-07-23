use strict;
use warnings;
use Test::More;

use_ok 'Test::Double';

my $double = Test::Double->new;
$double->expects('print')->code(
    sub { like($_[1], qr/^hello /) }
);

my $io = $double->replay;
$io->print('hello world');

ok($double->verify);

done_testing;
