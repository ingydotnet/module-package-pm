##
# name:      inc::Package
# abstract:  inc::Module::Install on Kool-aid. Oh Yeah!
# author:    Ingy döt Net <ingy@ingy.net>
# license:   perl
# copyright: 2011

package inc::Module::Package;
$VERSION = '0.11';
{
    package main;
    use Module::Package;
}

1;

=head1 SYNOPSIS

In you C<Makefile.PL>:

    use inc::Package;

=head1 DESCRIPTION

This is the inc::Module::Package bootstrapping module.
It works something like inc::Module::Install.
This code should only be loaded in an author environment.

See L<Module::Package> for more information.
