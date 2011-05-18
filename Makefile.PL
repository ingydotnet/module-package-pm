# This 'use lib' statement is not required for normal usage of
# inc::Module::Package, and technically it is not required here. But having it
# avoids subtle bootstrapping bugs that can arise during the development and
# deployment of this module.
use lib 'lib';

# This line does all the normal stuff. It invokes pkg/makefile.pl to do any
# other stuff you want to add.
use inc::Module::Package;

# But you still put 'requires' statements in here (and anything else that
# needs to run at module installation time).
requires 'Module::Install' => '1.01';
requires 'Module::Install::ManifestSkip';
