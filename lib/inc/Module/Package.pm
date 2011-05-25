##
# name:      inc::Package
# abstract:  inc::Module::Install on Kool-aid. Oh Yeah!
# author:    Ingy döt Net <ingy@ingy.net>
# license:   perl
# copyright: 2011

package inc::Module::Package;
$VERSION = '0.11';

BEGIN {
    package main;
    use Module::Package();
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

This is the inc::Module::Package bootstrapping module.  It works something
like inc::Module::Install.  This bootstrap module should only be loaded in an
author environment.

See L<Module::Package> for more information.
