package Test::Retry;
use strict;
use warnings;
use 5.008_001;
use Test::Builder;
use Time::HiRes qw(sleep);

use Exporter::Lite;

our $VERSION = '0.01';

our @EXPORT = qw(retry_test);

our $MAX_RETRIES    = 5;
our $RETRY_INTERVAL = 0.5;

sub retry_test (&) {
    my $block = shift;

    my $retry;
    my $count = 0;

    my $ORIGINAL_ok = \&Test::Builder::ok;

    no warnings 'redefine';
    local *Test::Builder::ok = sub {
        my ($self, $test, $name) = @_;

        $retry = 0;
        $name = '' unless defined $name;

        if ($test) {
            goto \&$ORIGINAL_ok; # passes
        } elsif ($count++ >= $MAX_RETRIES) {
            $self->diag("test '$name' failing; give up");
            goto \&$ORIGINAL_ok; # fails
        } else {
            $self->diag("test '$name' failing; retry ($count/$MAX_RETRIES)");
            $retry++;
        }
    };

    &$block;

    while ($retry) {
        sleep $RETRY_INTERVAL;
        &$block;
    }
}

1;

__END__

=head1 NAME

Test::Retry - 

=head1 SYNOPSIS

  use Test::Retry;

=head1 DESCRIPTION

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
