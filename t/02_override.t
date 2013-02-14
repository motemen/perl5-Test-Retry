use strict;
use warnings;
use Test::More;
use Test::Retry;

BEGIN { Test::Retry->override('is') }

my $x = 0;

is { $x++, '2', '$x++ == 2' };

done_testing;
