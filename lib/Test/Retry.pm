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

sub override {
    my $class = shift;

    foreach my $name (@_) {
        my $pkg = caller;

        my $original_code = $pkg->can($name);
        my $code = sub (&) {
            my $block = shift;
            Test::Retry::retry_test {
                my @args = $block->();
                $original_code->(@args);
            };
        };

        no strict 'refs';
        no warnings 'redefine', 'prototype';
        *{"$pkg\::$name"} = \&$code;
    }
}

1;

__END__

=head1 NAME

Test::Retry - Retry test functions on failure

=head1 SYNOPSIS

  use Test::Retry;

  # Retries for 5 times with 0.5 secs delay each
  retry_test {
      is func_with_some_random_lag(), $expected;
  };

  # or override existing test functions

  BEGIN { Test::Retry->override('is') }

  is { func_with_some_random_lag(), $expected };

=head1 DESCRIPTION

Test::Retry provides feature to retry code until a test succeeds (with retry limits).

Useful for tests which involves I/O and requires some wait to pass, for example.

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
