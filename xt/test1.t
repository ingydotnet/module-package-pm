# Test to make sure that a package builds and is installable.
use Test::More tests => 1;
use strict;
use Cwd qw'cwd abs_path';

die "Use devel-local" unless 
    $ENV{PERL5LIB} =~ /module-package-pm/;

delete $ENV{PERL_CPANM_OPT};
chdir 'xt/Foo1' or die;
if (-e 'Makefile') {
    system("make purge") == 0 or die;
    system("rm -fr local") == 0 or die;
}
system("perl Makefile.PL") == 0 or die;
system("make manifest") == 0 or die;
system("make dist") == 0 or die;
system("cpanm -l local Foo-1.23.tar.gz") == 0 or die;

ok -e 'local/lib/perl5/Foo.pm', 'Install works on user end';

system("make purge") == 0 or die;
system("rm -fr local") == 0 or die;
