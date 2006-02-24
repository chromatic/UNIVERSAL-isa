#!/usr/bin/perl -w

package UNIVERSAL::isa;

use strict;
use vars qw/$VERSION $recursing/;

use UNIVERSAL ();

use Scalar::Util qw/blessed/;
use warnings::register;

$VERSION = "0.06";

my $orig;
BEGIN { $orig = \&UNIVERSAL::isa };

no warnings 'redefine';

sub import
{
	no strict 'refs';
	*{caller() . "::isa"} = \&UNIVERSAL::isa if (@_ > 1 and $_[1] eq "isa");
}

sub UNIVERSAL::isa
{
	goto &$orig if $recursing;
	my $type = invocant_type( @_ );
	$type->( @_ );
}

sub invocant_type
{
	my $invocant = shift;
	return \&nonsense          unless defined( $invocant );
	return \&object_or_class   if blessed( $invocant );
	return \&reference         if ref( $invocant );
	return \&nonsense          unless $invocant;
	return \&object_or_class;
}

sub nonsense
{
	report_warning( 'on invalid invocant' );
	return;
}

sub object_or_class
{
	report_warning();

	local $@;
	local $recursing = 1;

	if ( my $override = eval { $_[0]->can( 'isa' ) } )
	{
		unless ( $override == \&UNIVERSAL::isa )
		{
			my $obj = shift;
			return $obj->$override( @_ );
		}
	}

	goto &$orig;
}

sub reference
{
	report_warning( "Did you mean to use Scalar::Util::reftype() instead?" );
	goto &$orig;
}

sub report_warning
{
	my $extra   = shift;
	$extra      = $extra ? " ($extra)" : '';

	if (warnings::enabled())
	{
		my $calling_sub  = ( caller( 2 ) )[3] || '';
		return if $calling_sub =~ /::isa$/;
		warnings::warn(
			"Called UNIVERSAL::isa() as a function, not a method$extra"
		)
	}
}

__PACKAGE__;

__END__

=pod

=head1 NAME

UNIVERSAL::isa - Attempt to recover from people calling UNIVERSAL::isa as a
function

=head1 SYNOPSIS

	# from the shell
	echo 'export PERL5OPT=-MUNIVERSAL::isa' >> /etc/profile

	# within your program
	use UNIVERSAL::isa;

=head1 DESCRIPTION

Whenever you use L<UNIVERSAL/isa> as a function, a kitten using
L<Test::MockObject> dies. Normally, the kittens would be helpless, but if they
use L<UNIVERSAL::isa> (the module whose docs you are reading), the kittens can
live long and prosper.

This module replaces C<UNIVERSAL::isa> with a version that makes sure that,
when called as a function on objects which override C<isa>, C<isa> will call
the appropriate method on those objects

In all other cases, the real C<UNIVERSAL::isa> gets called directly.

=head1 WARNINGS

If the lexical warnings pragma is available, this module will emit a warning
for each naughty invocation of C<UNIVERSAL::isa>. Silence these warnings by
saying:

	no warnings 'UNIVERSAL::isa';

in the lexical scope of the naughty code.

=head1 SEE ALSO

L<UNIVERSAL::can> for a more mature discussion of the problem at hand.

L<Test::MockObject> for one example of a module that really needs to override
C<isa()>.

=head1 AUTHORS

Autrijus Tang <autrijus@autrijus.org>

chromatic <chromatic@wgz.org>

Yuval Kogman <nothingmuch@woobling.org>

=head1 COPYRIGHT & LICENSE

Same as Perl, (c) 2005 - 2006.

=cut
