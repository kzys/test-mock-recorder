use strict;
use warnings;
use Test::More;

use_ok 'Test::Double';

{
    my $double = Test::Double->new;
    $double->expects('print')->with(['hello world']);

    $double->replay(
        sub {
            shift->print('hello world');
        }
    );

    $double->replay(
        sub {
            eval {
                shift->print('hello foobar');
            };
            ok($@, 'bad arguments');
        }
    );
};

{
    my $double = Test::Double->new;
    $double->expects('close')->with([]);

    my $io;

    $io = $double->replay;
    $io->close;
    ok($double->verify($io));

    $io = $double->replay;
    eval {
        $io->close('foobar');
    };
    ok($@, 'This is why arrayref');
};


{
    my $double = Test::Double->new;
    $double->expects('print')->code(
        sub { like($_[1], qr/^hello /) }
    );

    my $io = $double->replay;
    $io->print('hello foobar');
    ok($double->verify($io));
};

done_testing;
