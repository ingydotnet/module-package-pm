# Test to make sure that a package builds and is installable.
use Test::More tests => 1;
use xt::Test;

die "Use devel-local" unless 
    $ENV{PERL5LIB} =~ /module-package-pm/;

delete $ENV{PERL_CPANM_OPT};
chdir 'xt/Foo1' or die;
if (-e 'Makefile') {
    run "make purge";
    run "rm -fr local";
}
run "perl Makefile.PL";
run "make manifest";
run "make dist";

my $local = abs_path 'xt/local';
run "cpanm -l $local Foo-1.23.tar.gz";
ok -e "$local/lib/perl5/Foo.pm", 'Install works on user end';

run "make purge";
run "rm -fr local";
