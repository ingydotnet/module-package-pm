package Module::Package::Dist::Quux;

package Module::Package::Dist::Quux::basic;

use base qw[Module::Package::Dist];

sub _main
{
	my ($self) = @_;
	return if $self->mi->is_admin;
	return unless $ENV{'PERL_SHOULD_MODIFY_BAR1'};
	warn "Modifying Bar1.pm";
	open my $pkg, ">>", "lib/Bar1.pm";
	print $pkg "\n\n0a4d55a8d778e5022fab701977c5d840bbc486d0\n\n";
	close $pkg;
}

1;
