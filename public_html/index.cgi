#!/usr/bin/perl

use strict;
use warnings;

use lib '../herderite';
use conf;
use Front;

&Main();

sub Main
{
	my $front = new Front( &conf::param( {} ) );

	$front->init();

	$front->out();
}
