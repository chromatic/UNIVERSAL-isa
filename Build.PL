#!/usr/bin/perl -w

use strict;

use Module::Build;

Module::Build->new(
	module_name => 'UNIVERSAL::isa',
	license => 'perl',
	requires => {
		'perl' => '5.006',
		'Scalar::Util' => 0,
	},
	create_makefile_pl => 'traditional',
	sign => 1,
)->create_build_script;
