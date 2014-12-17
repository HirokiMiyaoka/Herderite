#!/usr/bin/perl

use strict;
use warnings;

use lib "../private_html";
use conf;
use Front;

&Main();

sub Main()
{
	my $front = new Front( &conf::param( {} ) );

	$front->out();
}
