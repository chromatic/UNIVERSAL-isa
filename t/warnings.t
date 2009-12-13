#! perl

use strict;
use warnings;

use Test::More tests => 9;

BEGIN { use_ok('UNIVERSAL::isa', 'isa') };

use warnings 'UNIVERSAL::isa';

{
    package Foo;

    sub isa { 1 }
}

{
    package Bar;
}

my $foo = bless {}, 'Foo';
my $bar = bless {}, 'bar';

{
    my $warning          = '';
    local $SIG{__WARN__} = sub { $warning = shift };

    UNIVERSAL::isa( $foo, 'Foo' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        'U::i should warn by default when redirecting to overridden method' );

    $warning = '';
    UNIVERSAL::isa( $foo, 'Bar' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        '... even if isa() would return false' );

    $warning = '';
    UNIVERSAL::isa( $bar, 'Foo' );
    is( $warning, '', '... but not by default on default isa()' );

    $warning = '';
    UNIVERSAL::isa( $bar, 'Bar' );
    is( $warning, '', '... even when it would return false' );
}

{
    UNIVERSAL::isa::->import( 'verbose' );

    my $warning          = '';
    local $SIG{__WARN__} = sub { $warning = shift };

    UNIVERSAL::isa( $foo, 'Foo' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        'U::i should warn when verbose when redirecting to overridden method' );

    $warning = '';
    UNIVERSAL::isa( $foo, 'Bar' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        '... even if isa() would return false' );

    $warning = '';
    UNIVERSAL::isa( $bar, 'Foo' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        '... and on default isa()' );

    $warning = '';
    UNIVERSAL::isa( $bar, 'Bar' );
    like( $warning, qr/Called UNIVERSAL::isa\(\) as a function.+warnings.t/,
        '... even when it would return false' );
}
