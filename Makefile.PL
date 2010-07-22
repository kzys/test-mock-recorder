#! perl
use inc::Module::Install;

name 'Test-Double';
all_from 'lib/Test/Double.pm';

requires 'Test::MockObject' >= 0;
requires 'Class::Accessors::Fast' => 0;
test_requires 'Test::More' => 0;

WriteAll;
