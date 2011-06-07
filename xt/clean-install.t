# Test to make sure that a package builds and is installable.
use Test::More tests => 1;
use xt::Test;

die "Use devel-local" unless 
    $ENV{PERL5LIB} =~ /module-package-pm/;

chdir 'xt/Foo1' or die;
if (-e 'Makefile') {
    run "make purge";
}
run "perl Makefile.PL";
run "make manifest dist";
run "tar xzf Foo-1.23.tar.gz";
run "cp Makefile2.PL Foo-1.23/";
chdir 'Foo-1.23' or die;
run "cat Makefile2.PL";
run "perl Makefile2.PL";
chdir '..' or die;

pass 'Works on clean install';

run "make purge";

