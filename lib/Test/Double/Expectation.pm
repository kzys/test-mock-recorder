package Test::Double::Expectation;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_ro_accessors(qw(method));
__PACKAGE__->mk_accessors(qw(method returns dies code with));

1;
