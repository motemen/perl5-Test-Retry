use strict;
use warnings;
use Test::More;
use Test::Retry;

my $x = 0;

retry_test {
    is $x++, 2, '$x++ == 2';
};

ok ! do {
    local $Test::Builder::Test = do {
        my $builder = Test::Builder->create;
        $builder->output(\(my $output = ''));
        $builder->failure_output(\(my $failure_output = ''));
        $builder->todo_output(\(my $todo_output = ''));
        $builder;
    };

    subtest 'fails' => sub {
        retry_test {
            is 'a', 'b', 'a eq b';
        };
    };

    Test::More->builder->is_passing;
},
'expectedly fails';

done_testing;
