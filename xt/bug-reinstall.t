# Test to make sure new Module::Package can replace old one.
use Test::More tests => 1;
use xt::Test;

delete $ENV{PERL5LIB};
delete $ENV{PERL_CPANM_OPT};
run "make purge", 1;
# -Ilib needed or else M:I:P is wrong.
run "perl -Ilib Makefile.PL";
run "make manifest";
run "make dist";
my $tarball = glob("*.tar.gz");
my $local = abs_path 'xt/local' or die;
run "rm -fr $local";

run "cpanm -l $local $tarball";
ok -e "$local/lib/perl5/inc/Module/Package.pm",
    'Install works on user end';
if (-e "$local/lib/perl5/inc/Module/Package.pm") {
    run "rm -fr $local";
}

#-- Run this for finer tuned debugging
# run "tar xzf $tarball";
# (my $dir = $tarball) =~ s/\.tar\.gz$// or die;
# $ENV{PERL5LIB} = abs_path 'xt/bug-reinstall/lib/';
# chdir $dir or die;
# run "perl Makefile.PL";
# pass 'Makefile.PL ran';
