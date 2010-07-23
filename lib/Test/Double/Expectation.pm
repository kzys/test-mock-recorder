package Test::Double::Expectation;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(method));
__PACKAGE__->mk_accessors(qw(method returns dies code));

use Data::Compare;
use Data::Dumper;

sub with {
    my ($self, $argv_ref) = @_;

    if ($argv_ref) {
        $self->{with} = $argv_ref;
        return $self;
    } else {
        return $self->{with};
    }
}

sub verify {
    my ($self, @argv) = @_;

    if ($self->code) {
        return $self->code->(@argv);
    } else {
        if ($self->with) {
            if (Compare($self->with, [ splice @argv, 1 ])) {
                ;
            } else {
                die sprintf(
                    qq{Expected method "%s" called, but the arguments are not expected.},
                    $self->method,
                );
            }
        }

        if ($self->dies) {
            die $self->dies;
        } else {
            return $self->returns;
        }
    }
}

1;
