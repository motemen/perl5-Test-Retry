use inc::Module::Install;

name 'Test-Retry';
all_from 'lib/Test/Retry.pm';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';

auto_set_repository;
auto_include_deps;

readme_markdown_from 'lib/Test/Retry.pm';

if ($Module::Install::AUTHOR) {
    require File::Copy;
    File::Copy::mv('README.mkdn', 'README.md');
}

WriteAll;
