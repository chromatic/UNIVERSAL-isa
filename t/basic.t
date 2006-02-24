#!/usr/bin/perl -w

use strict;

use Test::More tests => 18;

BEGIN { use_ok("UNIVERSAL::isa", "isa") };

# no warnings "UNIVERSAL::isa";
use warnings;

{
	package Foo;

	sub isa {
		1;
	}
}

{
	package Bar;
}

{
	package Gorch;
	sub isa {
		my $self = shift;
		my $class = shift;
		($class eq "Dung") || $self->SUPER::isa($class);
	}
}

{
	package Baz;
	sub isa {
		my $self = shift;
		my $class = shift;
		($class eq "Dung") || UNIVERSAL::isa($self, $class);
	}
}

my ($f,$b,$g,$x) = map { bless [], $_ } qw/Foo Bar Gorch Baz/;

ok(isa([], "ARRAY"), "10 is a scalar");
ok(isa($b, "Bar"), "bar is a bar");
ok(isa($f, "Foo"), "foo is a foo");
ok(!isa($b, "Crap"), "bar isn't full of crap");
ok(isa($f, "Crap"), "foo is full of crap");
ok(isa($g, "Gorch"), "gorch is itself");
ok(!isa($g, "Crap"), "gorch isn't crap");
ok(isa($g, "Dung"), "it's dung");
ok(isa($x, "Baz"), "baz is itself");
ok(!isa($x, "Crap"), "baz isn't crap");
ok(isa($x, "Dung"), "it's dung");
{
	use warnings 'UNIVERSAL::isa';
	no warnings 'once';

	ok( isa( {},     'HASH' ),      'hash reference isa HASH'     );
	ok( isa( [],     'ARRAY' ),     'array reference isa ARRAY'   );
	ok( isa( sub {}, 'CODE' ),      'code reference isa CODE'     );
	ok( isa( \my $a, 'SCALAR' ),    'scalar reference isa SCALAR' );
	ok( isa( qr//, 'Regexp' ),      'regexp reference isa Regexp' );
	ok( isa( \local *FOO, 'GLOB' ), 'glob reference isa GLOB'     );
}
