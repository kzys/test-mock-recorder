use strict;
use warnings;
use Test::More;

sub synopsis_of {
    my ($path) = @_;

    open(my $file, $path);
    my $src = do {
        local $/;
        <$file>
    };

    my $result;
    if ($src =~ qr/^=head1\sSYNOPSIS\n(.*?)^=head1/xms) {
        $result = $1;
    }

    close($file);
    return $result;
}

use_ok 'Test::Mock::Record';

my $src = synopsis_of('lib/Test/Mock::Record.pm');
eval($src);

is("$@", '', 'eval synopsis');

done_testing;
