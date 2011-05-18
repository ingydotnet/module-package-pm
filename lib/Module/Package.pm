package Module::Package;

$VERSION = '0.11';

{
    package main;
    use inc::Module::Install;
    pkg;
}

my $target_file = 'inc/Module/Package.pm';
if (-e 'inc/.author' and not -e $target_file) {
    my $source_file = $INC{'Module/Package.pm'}
        or die "Can't bootstrap inc::Module::Package";
    Module::Install::Admin->copy($source_file, $target_file);
}

1;

=head1 NAME

Module::Package - Postmodern Perl Module Packaging

=head1 SYNOPSIS

In you C<Makefile.PL>:

    use inc::Package;

=head1 DESCRIPTION

This module is a dropin replacement for L<Module::Install>. It does everything
Module::Install does, but just a bit better.

Now that you've heard the sell, here's the simple truth. Module::Package is an
exteremely tiny wrapper around Module::Install. All it does is load
Module::Install and call the C<pkg> directive. This in turn, loads
L<Module::Install::Package>.

But that's where the magic begins. Module::Install::Package attempts to fix
most of the problems of Module::Install, in one go.

=head1 MORE DOCUMENTATION

Coming soon...

=head1 FUN FACTS

This module uses itself to package itself. Take a look!

C<lexicals.pm> was shipped to CPAN using Module::Package before
Module::Package was released. Even if Module::Package had never been released,
lexicals.pm would still work.

=head1 STATUS

This is a early, "proving concepts", release. Keep out.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
