##
# name:      Module::Package::Plugin
# abstract:  Base class for Module::Package author-side plugins
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

package Module::Package::Plugin;
use Moo 0.009007;

our $VERSION = '0.11';

has 'mi' => (is => 'rw');

my $BUILD = 0;
sub BUILD {
    $BUILD++;
}

sub main {
    my ($self) = @_;
    die ref($self) . " needs to provide a method called 'main()'";
}

my $WriteAll = 0;
sub WriteAll {
    return if $WriteAll++;
    my $self = shift;
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

sub _replicate {
    my $target_file = 'inc/Module/Package.pm';
    if (-e 'inc/.author' and not -e $target_file) {
        my $source_file = $INC{'Module/Package.pm'}
            or die "Can't bootstrap inc::Module::Package";
        Module::Install::Admin->copy($source_file, $target_file);
    }
}

1;
