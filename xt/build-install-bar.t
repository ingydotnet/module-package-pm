# Test to make sure that a package builds and is installable.
use Test::More tests => 2;
use xt::Test;

die "Use devel-local" unless 
    $ENV{PERL5LIB} =~ /module-package-pm/;

run "rm -f xt/Bar1/Bar1-0.001.tar.gz";

my $local = abs_path 'xt/local';
delete $ENV{PERL_CPANM_OPT};
chdir 'xt/Bar1' or die;
if (-e 'Makefile') {
    run "make purge";
    run "rm -fr $local";
}
run "perl Makefile.PL";
run "make manifest";
run "make dist";

$ENV{PERL_SHOULD_MODIFY_BAR1} = 1;
run "cpanm -l $local Bar1-0.001.tar.gz";
ok -e "$local/lib/perl5/Bar1.pm", 'Install works on user end';

my $found = 0;
open my $fh, "$local/lib/perl5/Bar1.pm";
while (my $line = <$fh>) {
	if ($line =~ /0a4d55a8d778e5022fab701977c5d840bbc486d0/i) {
		++$found and last;
	}
}
close $fh;

ok $found, "Dist plugin worked";

run "make purge";
run "rm -fr $local";
(my $dir = $local) =~ s{local/?$}{Bar1};
run "rm -f $dir/Bar1-0.001.tar.gz";
run "mv $dir/MANIFEST.bak $dir/MANIFEST";
