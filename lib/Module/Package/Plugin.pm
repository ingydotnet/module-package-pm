##
# name:      Module::Package::Plugin
# abstract:  Base class for Module::Package author-side plugins
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

package Module::Package::Plugin;
use 5.008003;
use Moo 0.009007;
use Module::Install::AuthorRequires 0.02;
use Module::Install::ManifestSkip 0.15;
use IO::All 0.41;
use File::Find 0 ();

our $VERSION = '0.12';

has mi => (is => 'rw');
has options => (
    is => 'rw',
    lazy => 1,
    builder => '_build_options',
);
sub _build_options {
    my ($self) = @_;
    $self->mi->package_options;
}

#-----------------------------------------------------------------------------#
# These 3 functions (initial, main and final) make up the Module::Package
# plugin API. Subclasses MUST override 'main', and should rarely override
# 'initial' and 'final'.
#-----------------------------------------------------------------------------#
sub initial {
    my ($self) = @_;
    # Load pkg/conf.yaml if it exists
    $self->mi->_guess_pm;
    $self->eval_deps_list;
}

sub main {
    my ($self) = @_;
    my $class = ref($self);
    die "$class cannot be used as a Module::Package plugin. Use a subclass"
        if $class eq __PACKAGE__;
    die "$class needs to provide a method called 'main()'";
}

sub final {
    my ($self) = @_;
    $self->manifest_skip;
    $self->mi->_install_bin;
    $self->WriteAll;
    $self->write_deps_list;
}

#-----------------------------------------------------------------------------#
# This is where the useful methods (that author plugins can invoke) live.
#-----------------------------------------------------------------------------#
sub pod_or_pm_file {
    # XXX $main::POD should be overloaded to always return the best thing.
    if (! $main::POD) {
        (my $pod = $main::PM) =~ s/\.pm$/.pod/ or die;
        $main::POD = $pod if -e $pod;
    }
    return $main::POD || $main::PM;
}
sub pm_file {
    return $main::PM;
}

my $deps_list_file = 'pkg/deps_list.pl';
sub eval_deps_list {
    my ($self) = @_;
    return if not $self->options->{deps_list};
    my $data = '';
    if (-e 'Makefile.PL') {
        my $text = io('Makefile.PL')->all;
        if ($text =~ /.*\n__(?:DATA|END)__\r?\n(.*)/s) {
            $data = $1;
        }
    }
    if (-e $deps_list_file and -s $deps_list_file) {
        package main;
        require $deps_list_file;
    }
    elsif ($data) {
        package main;
        eval $data;
        die $@ if $@;
    }
}

sub write_deps_list {
    my ($self) = @_;
    return if not $self->options->{deps_list};
    my $text = $self->generate_deps_list;
    if (-e $deps_list_file) {
        my $old_text = io($deps_list_file)->all;
        $text .= "\n1;\n";
        if ($text ne $old_text) {
            warn "Updating $deps_list_file\n";
            io($deps_list_file)->print($text);
        }
        $text = '';
    }
    if (
        -e 'Makefile.PL' and
        io('Makefile.PL')->all =~ /^__(?:DATA|END)__$/m
    ) {
        my $perl = io('Makefile.PL')->all;
        my $old_perl = $perl;
        $perl =~ s/(.*\n__(?:DATA|END)__\r?\n).*/$1/s or die $perl;
        if (-e $deps_list_file) {
            io('Makefile.PL')->print($perl);
            return;
        }
        $perl .= "\n" . $text;
        if ($perl ne $old_perl) {
            warn "Updating deps_list in Makefile.PL\n";
            io('Makefile.PL')->print($perl);
            if (-e 'Makefile') {
                sleep 1;
                io('Makefile')->touch;
            }
        }
    }
    elsif ($text) {
        warn <<"...";
Note: Can't find a place to write deps list, and deps_list option is true.
      touch $deps_list_file or add __END__ to Makefile.PL.
      See 'deps_list' in Module::Package::Plugin documentation.
...
    }
}

sub generate_deps_list {
    my ($self) = @_;
    my @inc;
    File::Find::find(sub {
        return unless -f $_ and $_ =~ /\.pm$/;
        push @inc, $File::Find::name;
    }, 'inc');
    my $text = '';
    no strict 'refs';
    $text .= join '', map {
        my $version = ${"${_}::VERSION"} || '';
        if ($version) {
            "author_requires '$_' => '$version';\n";
        }
        else {
            "author_requires '$_';\n";
        }
    } grep {
        not m!^Module::(Package|Install)$! and
        not m!^Test::Base::.*$! and   # XXX this smells bad...
        not m!^Module::Install::(
            Admin |
            AuthorRequires |
            AutoInstall |
            Base |
            Bundle |
            Can |
            Compiler |
            Deprecated |
            DSL |
            External |
            Fetch |
            Include |
            Inline |
            Makefile |
            MakeMaker |
            ManifestSkip |
            Metadata |
            Package |
            PAR |
            Run |
            Scripts |
            Share |
            Win32 |
            With |
            WriteAll |
        )$!x;
    } map {
        s!inc[\/\\](.*)\.pm$!$1!;
        s!/+!::!g;
        $_;
    } sort @inc;
    my $module = ref($self);
    $module =~ s/::[a-z].*//;
    my $version = do {
        no strict 'refs';
        ${"${module}::VERSION"} || 0;
    };
    $text = <<"..." . $text if $text;
# Deps list generated by:
author_requires 'Module::Package' => '$Module::Package::VERSION';

author_requires '$module' => '$version';
...
    return $text;
}

# We generate a MANIFEST.SKIP and add things to it.
# We add pkg/, because that should only contain author stuff.
# We add author only M::I plugins, so they don't get distributed.
sub manifest_skip {
    my ($self) = @_;
    return if not $self->options->{manifest_skip};
    $self->mi->manifest_skip;

    # XXX Hardcoded author list for now. Need to change this.
    # One idea is to let Module::Package plugins declare which plugins are
    # Author-side only.
    # Consider $AUTHOR_ONLY globals...
    io('MANIFEST.SKIP')->append(<<'...');
^pkg/
^inc/Module/Install/AckXXX.pm$
^inc/Module/Install/AuthorRequires.pm$
^inc/Module/Install/ManifestSkip.pm$
^inc/Module/Install/ReadmeFromPod.pm$
^inc/Module/Install/Stardoc.pm$
^inc/Module/Install/TestML.pm$
^inc/Module/Install/VersionCheck.pm$
...

    $self->mi->clean_files('MANIFEST MANIFEST.SKIP');
}

sub check_use_test_base {
    my ($self) = @_;
    my @files;
    File::Find::find(sub {
        return unless -f $_ and $_ =~ /\.(pm|t)$/;
        push @files, $File::Find::name;
    }, 't');
    for my $file (@files) {
        if (io($file)->all =~ /\bTest::Base\b/) {
            $self->mi->use_test_base;
            return;
        }
    }
}

sub check_use_testml {
    my ($self) = @_;
    if (-e 't/testml') {
        $self->mi->use_testml;
    }
}

sub strip_extra_comments {
    # TODO later
}

#-----------------------------------------------------------------------------#
# These functions are wrappers around Module::Install functions of the same
# names. They are generally safer (and simpler) to call than the real ones.
# They should almost always be chosen by Module::Package::Plugin subclasses.
#-----------------------------------------------------------------------------#
my $WriteAll = 0;
sub WriteAll {
    return if $WriteAll++;
    my ($self) = @_;
    $self->_replicate;
    $self->mi->WriteAll;
}

my $all_from = 0;
sub all_from {
    return if $all_from++;
    my $self = shift;
    my $file = shift || $main::PM;
    $self->mi->all_from($file);
}

#-----------------------------------------------------------------------------#
# These are ugly housekeeping functions.
#-----------------------------------------------------------------------------#
sub _replicate {
    my $target_file = 'inc/Module/Package.pm';
    if (-e 'inc/.author' and not -e $target_file) {
        my $source_file = $INC{'Module/Package.pm'}
            or die "Can't bootstrap inc::Module::Package";
        Module::Install::Admin->copy($source_file, $target_file);
    }
}

sub _version_check {
    my ($self, $version) = @_;
    die <<"..." unless $version == $VERSION;

Error! Something has gone awry:
    Module::Package version=$version is using 
    Module::Package::Plugin version=$VERSION
If you are the author of this module, try upgrading Module::Package.
Otherwise, please notify the author of this error.

...
}

package Module::Package::Plugin::basic;
use Moo;
extends 'Module::Package::Plugin';

sub main {
    my ($self) = @_;
    $self->all_from;
}

1;

=head1 SYNOPSIS

    package Module::Package::Name;

    package Module::Package::Name::flavor;
    use Moo;
    extends 'Module::Package::Plugin';

    sub main {
        my ($self) = @_;
        $self->mi->some_module_install_author_plugin;
        $self->mi->other_author_plugin;
        $self->all_from;
    }

    1;

=head1 DESCRIPTION

This module is the base class for Module::Package plugins. 

... much more doc coming soon...

For now take a look at the L<Module::Package::Ingy> module.

=head1 OPTIONS

The following options are available for use from the Makefile.PL:

    use Module::Package 'Foo:bar',
        deps_list => 0,
        install_bin => 0,
        manifest_skip => 0;

These options can be used by any subclass of this module.

=head2 deps_list

Default is 1.

This option tells Module::Package to generate a C<author_requires> deps list,
when you run the Makefile.PL. This list will go in the file
C<pkg/deps_list.pl> if that exists, or after a '__END__' statement in your
Makefile.PL. If neither is available, a reminder will be warned (only when the
author runs it).

This list is important if you want people to be able to collaborate on your
modules easily.

=head2 install_bin

Default is 1.

All files in a C<bin/> directory will be installed. It will call the
C<install_script> plugin for you. Set this option to 0 to disable it.

=head2 manifest_skip

Default is 1.

This option will generate a sane MANIFEST.SKIP for you and delete it again
when you run C<make clean>. You can add your own skips in the file called
C<pkg/manifest.skip>. You almost certainly want this option on. Set to 0 if
you are weird.
