#!/usr/bin/perl

use strict;

use Test::More tests => 8;

BEGIN { use_ok('UNIVERSAL::isa', 'isa') };

no warnings 'UNIVERSAL::isa';

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

# really delegates calls to Foo
{
	package FooProxy;

	sub new
	{
		my $class = shift;
		my $foo   = Foo->new( @_ );
		bless \$foo, $class;
	}

	sub can
	{
		my $self = shift;
		return $$self->can( @_ );
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

is( scalar(isa(undef, 'Foo')), undef, 'isa on undef returns undef');

eval { require CGI };

unless ($@) {
	isa_ok(CGI->new(''), "CGI");
}

# overloaded objects
{
	package Qibble;
	use overload '""' => sub { die };
	no warnings 'once';
	*new = \&Foo::new;
}

my $qibble = Qibble->new();

ok(   isa( $qibble, 'Qibble' ), '... can test ISA on landmines');

my $proxy = FooProxy->new();
isa_ok( $proxy, 'Foo' );
