package Test::Double;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_mock _index _recorded));
use Test::MockObject;
use Test::Double::Expectation;

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        _mock  => Test::MockObject->new,
        _index => -1,
        _recorded => [],
    });
}

sub _slice {
    my ($n, @src) = @_;

    my $max = scalar @src / $n - 1;
    my @result;
    for my $i (0...$max) {
        push @result, [ map { $src[$i * $n + $_] } 0...$n ];
    }
    return @result;
}

sub _expects_one {
    my ($self, $method) = @_;

    $self->_mock->mock(
        $method => sub {
            my $record = $self->_recorded->[ $self->_index ];
            if (! $record) {
                die sprintf('"%s" called, but not expected', $method);
            }
            $self->{_index}++;
            if ($record->dies) {
                die $record->dies;
            } else {
                return $record->returns;
            }
        }
    );

    my $expectation = Test::Double::Expectation->new({
        method => $method
    });
    push @{ $self->_recorded }, $expectation;

    return $expectation;
}

sub expects {
    my $self = shift;

    if (scalar @_ == 1) {
        return $self->_expects_one(@_)
    }

    for (_slice(2, @_)) {
        my ($method, $return) = @{ $_ };
        $self->_expects_one($method)->returns($return);
    }
}

sub replay {
    my ($self) = @_;
    $self->{_index} = 0;
    return $self->_mock;
}

sub verify {
    my ($self) = @_;

    my $i = 1;
    for my $expects (@{ $self->_recorded }) {
        my @actual = $self->_mock->next_call;
        if (! $actual[0]) {
            warn sprintf(
                q{The %dth call of this instance isn't "%s"},
                $i, $expects->method
            );
        }
        if ($actual[0] && $expects->method eq $actual[0]) {
            ;
        } else {
            return 0;
        }
        $i++;
    }

    return 1;
}

1;
