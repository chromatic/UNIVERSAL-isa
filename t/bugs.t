#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

BEGIN { use_ok('UNIVERSAL::isa', 'isa') };

# class method

{
	package Foo;

	sub new
	{
		bless \(my $self), shift;
	}

	sub isa {
		1;
	}
}

# delegates calls to Foo
{
	package Bar;

	sub isa
	{
		return 1 if $_[1] eq 'Foo';
	}
}

# wraps a Foo object
{
	package Quux;

	use vars '$AUTOLOAD';
	sub isa;

	sub new
	{
		my $class = shift;
		my $foo   = Foo->new();
		bless \$foo, $class;
	}

	sub can
	{
		my $self = shift;
		return $$self->can( @_ );
	}

	sub AUTOLOAD
	{
		my $self     = shift;
		my ($method) = $AUTOLOAD =~ /::(\w+)$/;
		$$self->$method( @_ );
	}

	sub DESTROY {}
}

my $quux = Quux->new();

ok(   isa( 'Bar', 'Foo' ), 'isa() should work on class methods too'    );
ok( ! isa( 'Baz', 'Foo' ), '... but not for non-existant classes'      );
ok(   isa( $quux, 'Foo' ), '... and should work on delegated wrappers' );
