#
# name:      inc::Module::Package
# abstract:  Module::Package Bootstrapper
# author:    Ingy döt Net <ingy@ingy.net>
# license:   perl
# copyright: 2011
# see:
# - Module::Package

package inc::Module::Package;

BEGIN {
    $inc::Module::Package::VERSION = '0.18';
    unshift @INC, 'inc' unless $INC[0] eq 'inc';
    package main;
    use Module::Package 0.18 ();
    die "Module::Package Bootstrapping Error"
        unless $Module::Package::VERSION eq $inc::Module::Package::VERSION;
}

sub import {
    my $class = shift;
    Module::Package->import(@_);
}

1;

=head1 SYNOPSIS

In you C<Makefile.PL>:

    use inc::Module::Package <options>;

=head1 DESCRIPTION

This is the L<Module::Package> bootstrapping module.  It works something like
L<inc::Module::Install>.  This bootstrap module should only be loaded in an
author environment.

See L<Module::Package> for more information.
