##
# name:      Module::Install::Package
# abstract:  Module::Install support for Module::Package
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

package Module::Install::Package;
use strict;
use Module::Install::Base;
use vars qw'@ISA $VERSION';
@ISA = 'Module::Install::Base';
$VERSION = '0.12';

my $SELF;
my $PLUGIN;
sub package_init {
    my $self = $SELF = shift;
    $self->_guess_pm;
    return $SELF;
}
sub _package_plugin {
    my $self = shift;
    $PLUGIN = shift;
}

sub END {
    return unless $SELF;
    if ($PLUGIN) {
        $PLUGIN->WriteAll;
    }
}

# Take a guess at the primary .pm and .pod files for 'all_from', and friends.
# Put them in global vars in the main:: namespace.
sub _guess_pm {
    require File::Find;
    $main::PM = '';
    my $high = 999999;
    File::Find::find(sub {
        return unless /\.pm$/;
        my $name = $File::Find::name;
        my $num = ($name =~ s!/+!/!g);
        if ($num < $high) {
            $high = $num;
            $main::PM = $name;
            ($main::POD = $main::PM) =~ s/\.pm/.pod/ or die;
        }
    }, 'lib');
}

1;

=head1 SYNOPSIS

    use inc::Module::Package <options>;

=head1 DESCRIPTION

This Module::Install plugin provides user-side support for L<Module::Package>.
