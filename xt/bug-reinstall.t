# Test to make sure new Module::Package can replace old one.
use Test::More tests => 1;
use xt::Test;

delete $ENV{PERL5LIB};
run "make purge", 1;
run "perl Makefile.PL";
run "make manifest";
run "make dist";
my $tarball = glob("*.tar.gz");
run "tar xzf $tarball";
(my $dir = $tarball) =~ s/\.tar\.gz$// or die;
$ENV{PERL5LIB} = abs_path 'xt/bug-reinstall/lib/';
chdir $dir or die;
run "perl Makefile.PL";

pass;

exit;

my $local = abs_path 'xt/local';
run "cpanm -l $local Foo-1.23.tar.gz";
ok -e "$local/lib/perl5/Foo.pm", 'Install works on user end';
 
