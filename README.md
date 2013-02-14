# NAME

Test::Retry - Retry test functions on failure

# SYNOPSIS

    use Test::Retry;

    # Retries for 5 times with 0.5 secs delay each
    retry_test {
        is func_with_some_random_lag(), $expected;
    };

    # or override existing test functions

    BEGIN { Test::Retry->override('is') }

    is { func_with_some_random_lag(), $expected };

# DESCRIPTION

Test::Retry provides feature to retry code until a test succeeds (with retry limits).

Useful for tests which involves I/O and requires some wait to pass, for example.

# AUTHOR

motemen <motemen@gmail.com>

# SEE ALSO

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
