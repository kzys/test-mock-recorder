package Test::Double;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_mock _index _recorded));
use Test::MockObject;
use Test::Double::Expectation;

=head1 NAME

Test::Double - Record-and-verify interface for Test::MockObject

=head1 DESCRIPTION

Test::Double is a record-and-verify style Mocking library.

=head1 CLASS METHODS

=head2 new()

Constructor.

=cut

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        _mock  => Test::MockObject->new,
        _index => -1,
        _recorded => [],
    });
}

=head1 INSTANCE METHODS

=head2 expects($method)

Append exceptation of calling method named $method.

=cut

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

=head2 expects($method1 => $ret1, $method2 => $ret2, ...)

Short-form of one-argument "expects" method.

=cut

sub _slice {
    my ($n, @src) = @_;

    my $max = scalar @src / $n - 1;
    my @result;
    for my $i (0...$max) {
        push @result, [ map { $src[$i * $n + $_] } 0...$n ];
    }
    return @result;
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

=head2 replay()

=cut

sub replay {
    my ($self) = @_;
    $self->{_index} = 0;
    return $self->_mock;
}

=head2 verify()

=cut

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
__END__

=head1 AUTHOR

KATO Kazuyoshi E<lt>kato.kazuyoshi@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://code.google.com/p/pymox/> L<http://mocha.rubyforge.org/> L<http://xunitpatterns.com/Test%20Double.html>

=cut
