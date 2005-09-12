#!/usr/bin/perl -w

package UNIVERSAL::isa;

use strict;
use vars qw/$VERSION $recursing/;

use UNIVERSAL ();

use Scalar::Util qw/blessed/;
use warnings::register;

$VERSION = "0.04";

my $orig;
BEGIN { $orig = \&UNIVERSAL::isa };

no warnings 'redefine';

sub import {
	no strict 'refs';
	*{caller() . "::isa"} = \&UNIVERSAL::isa if (@_ > 1 and $_[1] eq "isa");
}

sub UNIVERSAL::isa {
	goto &$orig if not defined $_[0] or length $_[0] == 0;

	# not an object or a class name, we can skip
	unless ( blessed($_[0]) )
	{
		my $symtable = \%::;
		my $found    = 1;

		for my $symbol (split( '::', $_[0] ))
		{
			$symbol .= '::';
			unless (exists $symtable->{$symbol})
			{
				$found = 0;
				last;
			}
			$symtable = $symtable->{$symbol};
		}

		goto &$orig unless $found;
	}

	# 'isa' not overridden, we can skip
	goto &$orig if (UNIVERSAL::can($_[0], "isa") == \&UNIVERSAL::isa);

	# if we've been called from an overridden isa, we are either SUPER:: or explicitly called.
	# in both cases the original ISA behavior is expected.
	goto &$orig if $recursing;

	# the last possible case is that 'isa' is overridden
	local $recursing = 1;
	my $obj = shift;

	if (warnings::enabled()) {
		my $calling_sub  = ( caller( 1 ) )[3] || '';
		warnings::warn( "Called UNIVERSAL::isa() as a function, not a method" )
			if $calling_sub !~ /::isa$/;
	}

	return $obj->isa(@_);
}

__PACKAGE__;

__END__

=pod

=head1 NAME

UNIVERSAL::isa - Hack around stupid module authors using UNIVERSAL::isa as a
function when they shouldn't.

=head1 SYNOPSIS

	echo 'export PERL5OPT=-MUNIVERSAL::isa' >> /etc/profile

=head1 DESCRIPTION

Whenever you use L<UNIVERSAL/isa> as a function, a kitten using
L<Test::MockObject> dies. Normally, the kittens would be helpless, but if they
use L<UNIVERSAL::isa> (the module whose docs you are reading), the kittens can
live long and prosper.

This module replaces C<UNIVERSAL::isa> with a version that makes sure that if
it's called as a function on objects which override C<isa>, C<isa> will be
called on those objects as a method.

In all other cases the real C<UNIVERSAL::isa> is just called directly.

=head1 WARNINGS

If the lexical warnings pragma is available, a warning will be emitted for each
naughty invocation of C<UNIVERSAL::isa>. These warnings can be silenced by
saying:

	no warnings 'UNIVERSAL::isa';

in the lexical scope of the naughty code.

=head1 SEE ALSO

L<UNIVERSAL::can> for a more mature discussion of the problem at hand.

=head1 AUTHORS

Autrijus Tang <autrijus@autrijus.org>

chromatic <chromatic@wgz.org>

Yuval Kogman <nothingmuch@woobling.org>

=head1 COPYRIGHT & LICENSE

Same as perl, blah blah blah, (c) 2005

=cut


