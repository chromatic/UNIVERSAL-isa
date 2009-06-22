#! perl

BEGIN { require 5.006002 }

use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name => 'UNIVERSAL::isa',
    license     => 'perl',
    requires    => {
        'perl'         => '5.6.2',
        'Scalar::Util' => 0,
    },
    config_requires => {
        'perl'          => '5.6.2',
        'Module::Build' => '0.33',
    }
)->create_build_script;
