##
# name:      Module::Install::Package
# abstract:  Module::Install support for Module::Package
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

# This module contains the Module::Package logic that must be available to
# both the Author and the End User. Author-only logic goes in a
# Module::Package::Plugin subclass.
package Module::Install::Package;
use strict;
use Module::Install::Base;
use vars qw'@ISA $VERSION';
@ISA = 'Module::Install::Base';
$VERSION = '0.12';

#-----------------------------------------------------------------------------#
# We allow the author to specify key/value options after the plugin. These
# options need to be available both at author time and install time.
#-----------------------------------------------------------------------------#
# We won't use any non-core modules like Moo, here. (This runs on user side)
# Generate an accessor for command line options:
sub package_options {
    my $self = shift;
    return ($self->{package_options} = shift) if @_;
    return $self->{package_options};
}

my $default_options = {
    deps_list => 1,
    install_bin => 1,
    manifest_skip => 1,
};

#-----------------------------------------------------------------------------#
# Module::Install plugin directives. Use long, ugly names to not pollute the
# Module::Install plugin namespace. These are only intended to be called from
# Module::Package.
#-----------------------------------------------------------------------------#

# Module::Package starts off life as a normal call to this Module::Install
# plugin directive:
my $module_install_plugin;
my $module_package_plugin;
sub module_package_internals_init {
    my $self = $module_install_plugin = shift;
    my ($plugin_spec, %options) = @_;
    $self->package_options({%$default_options, %options});

    if ($module_install_plugin->is_admin) {
        $module_package_plugin = $self->_load_plugin($plugin_spec);
        $module_package_plugin->_version_check($VERSION);
        $module_package_plugin->mi($module_install_plugin);

        $module_package_plugin->initial;
        $module_package_plugin->main;
    }
    else {
        $module_install_plugin->_initial();
        $module_install_plugin->_main();
    }
    # If this Module::Install plugin was used (by Module::Package) then wrap
    # up any loose ends. This will get called after Makefile.PL has completed.
    sub END {
        return unless $module_install_plugin;
        $module_package_plugin
            ? $module_package_plugin->final
            : $module_install_plugin->_final;
    }
}

# Module::Package, Module::Install::Package and Module::Package::Plugin
# must all have the same version. Seems wise.
sub module_package_internals_version_check {
    my ($self, $version) = @_;
    die <<"..." unless $version == $VERSION;

Error! Something has gone awry:
    Module::Package version=$version is using 
    Module::Install::Package version=$VERSION
If you are the author of this module, try upgrading Module::Package.
Otherwise, please notify the author of this error.

...
}

sub package_author_requires {
    my ($self, $module, $version) = @_;
    return unless $self->is_admin;

    eval "require $module; 1"
        or warn "Warning: As a Package Author, you need to install '$module'\n";
}

# Find and load the author side plugin:
sub _load_plugin {
    my ($self, $spec) = @_;
    my ($module, $plugin) =
        not(defined $spec) ? ('Plugin', "Plugin::basic") :
        ($spec =~ /^\w(\w|::)*$/) ? ($spec, $spec) :
        ($spec =~ /^:(\w+)$/) ? ('Plugin', "Plugin::$1") :
        ($spec =~ /^(\S*\w):(\w+)$/) ? ($1, "$1::$2") :
        die "$spec is invalid";
    $module = "Module::Package::$module";
    $plugin = "Module::Package::$plugin";
    eval "require $module; 1" or die $@;
    return $plugin->new();
}

#-----------------------------------------------------------------------------#
# These are the user side analogs to the author side plugin API calls.
# Prefix with '_' to not pollute Module::Install plugin space.
#-----------------------------------------------------------------------------#
sub _initial {
    my ($self) = @_;
    $self->_guess_pm;
}

sub _main {
    my ($self) = @_;
}

sub _final {
    my ($self) = @_;
    $self->all_from($main::PM)
        unless $self->name;
    $self->_install_bin;
    $self->WriteAll;
}

#-----------------------------------------------------------------------------#
# This section is where all the useful code bits go. These bits are needed by
# both Author and User side runs.
#-----------------------------------------------------------------------------#
# Take a guess at the primary .pm and .pod files for 'all_from', and friends.
# Put them in global vars in the main:: namespace.
sub _guess_pm {
    if (not $main::PM) {
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
            }
        }, 'lib');
    }
    (my $pod = $main::PM) =~ s/\.pm/.pod/ or die;
    $main::POD = -e $pod ? $pod : '';
}

sub _install_bin {
    my ($self) = @_;
    return unless $self->package_options->{install_bin};
    return unless -d 'bin';
    my @bin;
    File::Find::find(sub {
        return unless -f $_;
        push @bin, $File::Find::name;
    }, 'bin');
    $self->install_script($_) for @bin;
}

1;

=head1 SYNOPSIS

    use inc::Module::Package <options>;

=head1 DESCRIPTION

This Module::Install plugin provides user-side support for L<Module::Package>.
