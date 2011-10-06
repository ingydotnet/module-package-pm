package Bar1;

use 5.006;
use strict;
use constant { FALSE => 0, TRUE => 1 };
use utf8;

BEGIN {
	$Bar1::AUTHORITY = 'cpan:TOBYINK';
}
BEGIN {
	$Bar1::VERSION   = '0.001';
}

sub bar1
{
	print "Hello World";
}

TRUE;

__END__

=head1 NAME

Bar1 - a module that does something-or-other

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Bar1>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

