use inc::Module::Package 0.18 'Ingy:modern 0.05';

# The default module 'lib/Module/Package.pm' has to be very strict
# and minimal, so we get much of the package info from here:
perl_version_from 'lib/Module/Package/Plugin.pm';
requires_from 'lib/Module/Package/Plugin.pm';
