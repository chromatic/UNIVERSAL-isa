#!/usr/bin/perl

package UNIVERSAL::isa;

use strict;
use warnings;
use UNIVERSAL ();

use Scalar::Util qw/blessed/;

our $VERSION = "0.01";

my $orig;
BEGIN { $orig = \&UNIVERSAL::isa };

no warnings 'redefine';

sub import {
	no strict 'refs';
	*{caller() . "::isa"} = \&UNIVERSAL::isa if (@_ > 1 and $_[1] eq "isa");
}

sub UNIVERSAL::isa {
	# not an object, we can skip
	goto &$orig unless blessed($_[0]);

	# 'isa' not overridden, we can skip
	goto &$orig if (UNIVERSAL::can($_[0], "isa") == \&UNIVERSAL::isa);

	# if we've been called from an overridden isa, we are either SUPER:: or explicitly called.
	# in both cases the original ISA behavior is expected.
	our $recursing;
	goto &$orig if $recursing;

	# the last possible case is that 'isa' is overridden
	local $recursing = 1;
	my $obj = shift;
	return $obj->isa(@_);	
}

__PACKAGE__;

__END__

=pod

=head1 NAME

UNIVERSAL::isa - Hack around stupid module authors using UNIVERRSAL::isa as a
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

=head1 AUTHOR

Yuval Kogman <nothingmuch@woobling.org>

=head1 COPYRIGHT & LICENSE

Same as perl, blah blah blah, (c) 2005

=cut


