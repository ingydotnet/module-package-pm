package Module::Package;
use strict;
use 5.005;

$Module::Package::VERSION = '0.11';

sub import {
    my $class = shift;
    my $mi = $class->load_module_install;
    if ($mi->is_admin) {
        my $plugin = $class->load_plugin(@_);
        $plugin->mi($mi);
        $mi->_package_plugin($plugin);
        $plugin->main;
    }
}

sub load_module_install {
    package main;
    require inc::Module::Install;
    inc::Module::Install->import();
    return package_init();
}

sub load_plugin {
    my ($class, $spec, @options) = @_;
    my ($module, $plugin) =
        not(defined $spec) ? ('Common', "Common::basic") :
        ($spec =~ /^\w(\w|::)*$/) ? ($spec, $spec) :
        ($spec =~ /^:(\w+)$/) ? ('Common', "Common::$1") :
        ($spec =~ /^(\S*\w):(\w+)$/) ? ($1, "$1::$2") :
        die "$spec is invalid";
    $module = "Module::Package::$module";
    $plugin = "Module::Package::$plugin";
    eval "require $module; 1" or die $@;
    my $plugin_object = $plugin->new(@options);
}

1;

=head1 NAME

Module::Package - Postmodern Perl Module Packaging

=head1 SYNOPSIS

In your C<Makefile.PL>:

    use inc::Module::Package;

or one of these invocations:

    # Bare bones Module::Package
    use inc::Module::Package ':basic';

    # With Module::Package::Catalyst plugin options
    use inc::Module::Package 'Catalyst';

    # With Module::Package::Catalyst::common class
    use inc::Module::Package 'Catalyst:common';

    # Pass options to the Module::Package::Ingy::special constructor
    use inc::Module::Package 'Ingy:special',
        option1 => 'value1',
        option2 => 'value2';

=head1 DESCRIPTION

This module is a dropin replacement for L<Module::Install>. It does everything
Module::Install does, but just a bit better.

Actually this module is simply a wrapper around Module::Install. It attempts
to drastically reduce what goes in a Makefile.PL, while at the same time,
fixing many of the problems that people have had with Module::Install (and
other module frameworks) over the years.

=head1 FEATURES

Module::Package has many advantages over vanilla Module::Install.

=head2 Smaller Makefile.PL Files

In the majority of cases you can reduce your Makefile.PL to a single command.
The core Module::Package invokes the Module::Install plugins that it thinks
you want. You can also name the Module::Package plugin that does exactly the
plugins you want.

=head2 Reduces Module::Install Bloat

Somewhere Module::Install development went awry, and allowed modules that only
have useful code for an author, to be bundled into a distribution. Over time,
this has created a lot of wasted space on CPAN mirrors. Module::Package fixes
this.

=head2 Collaborator Plugin Discovery

An increasing problem with Module::Install is that when people check out your
module source from a repository, they don't know which Module::Install plugin
modules you have used. That's because the Makefile.PL only requires the
function names, not the module names that they come from.

Many people have realized this problem, and worked around it in various
unfortunate ways. Module::Package manages this problem for you.

=head2 Feature Grouping and Reuse

Module::Install has lots of plugins. Although it is possible with plain
Module::Install, nobody seems to make plugins that group other plugins. This
also might introduce subtle problems of using groups with other groups.

Module::Package has object oriented plugins whose main purpose is to create
these groups.

=head1 USAGE

The basic anatomy of a Makefile.PL call to Module::Package is:

    use inc::Module::Package PluginName:subclass_name %options;

The C<inc::Module::Package> part uses the Module::Install C<inc> bootstrapping
trick.

C<PluginName:subclass_name> (note the single ':') resolves to the inline class
C<Module::Package::PluginName::subclass_name>, with the module
C<Module::Package::PluginName>. Module::Package::PluginName::subclass_name
must be a subclass of L<Module::Package::Plugin>.

C<%options> means whatever follows on the command. These values are passed
directly to the constructor of Module::Package::PluginName::subclass_name.

If C<:subclass_name> is omitted, the class Module::Package::PluginName is
used. The idea is that you can create a single module with many different
plugin styles.

If C<PluginName> is omitted, then C<:subclass_name> is used against
L<Module::Package::Common>. These are a set of common plugin classes that you
can use.

If C<PluginName:subclass_name> is omitted altogether, it is the same as saying
'Common:basic'. Note that the constructor of Module::Package::Common::basic
takes no arguments.

=head1 STATUS

This is still an early release. You should probably avoid it for now. That
said, quite a few modules are using this in the wild. Caveat author.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
