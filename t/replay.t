use strict;
use warnings;
use Test::More;

use_ok 'Test::Double';
my $double = Test::Double->new;
isnt($double->replay, $double->replay);

done_testing;
