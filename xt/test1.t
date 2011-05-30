use Test::More tests => 1;
use strict;
my $lib;
use Cwd qw'cwd abs_path';
BEGIN { $lib = abs_path 'lib' }
use lib $lib;
use Capture::Tiny;
BEGIN { @INC = grep not(/site/), @INC};

chdir 'xt/Foo1' or die;
system("perl -I$lib Makefile.PL") == 0 or die;
system("make manifest") == 0 or die;


ok -e 'inc/Package.pm'

system("make purge") == 0 or die;
