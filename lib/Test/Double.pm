package Test::Double;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_mock _index _expectations));
use Test::MockObject;
use Test::Double::Expectation;

=head1 NAME

Test::Double - Record-and-verify style mocking library.

=head1 SYNOPSIS

  my $double = Test::Double->new
  $double->expects('print');
  
  my $io = $double->replay;
  $io->print('hello world');
  
  ok($io->verify);

=head1 DESCRIPTION

Test::Double is a record-and-verify style mocking library.

=head1 CLASS METHODS

=head2 new()

Constructor.

=cut

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        _mock  => Test::MockObject->new,
        _index => -1,
        _expectations => [],
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
            my $expectation = $self->_expectations->[ $self->_index ];
            if (! $expectation) {
                die sprintf('"%s" called, but not expected', $method);
            }

            $self->{_index}++;

            if ($expectation->dies) {
                die $expectation->dies;
            } else {
                return $expectation->returns;
            }
        }
    );

    my $result = Test::Double::Expectation->new({ method => $method });
    push @{ $self->_expectations }, $result;

    return $result;
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
        return $self->_expects_one(@_);
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
    for my $expectation (@{ $self->_expectations }) {
        my @actual = $self->_mock->next_call;
        if (! $actual[0]) {
            warn sprintf(
                q{The %dth call of this instance isn't "%s"},
                $i, $expectation->method
            );
        }
        if ($actual[0] && $actual[0] eq $expectation->method) {
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

=head1 DESIGN

Test::Dobule is heavily inspired from other language's mock library
Especially Mox (Python) and Mocha (Ruby).

But it has a little different interface.

=head2 "replay"

Test::Dobule's "replay" don't switch mode.

=head2 "excepts" vs. AUTOLOAD

Mox has AUTOLOAD-style interface.
However the interface need to reserve some method name,
such as "replay" or "verify".

And "Comparator" are difficult to learn.
L<http://code.google.com/p/pymox/wiki/MoxDocumentation#Comparators>

=head1 AUTHOR

KATO Kazuyoshi E<lt>kato.kazuyoshi@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://code.google.com/p/pymox/> L<http://mocha.rubyforge.org/> L<http://xunitpatterns.com/Test%20Double.html>

=cut
