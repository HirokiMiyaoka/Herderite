#!/usr/bin/perl

use strict;
use warnings;

use lib '../herderite';
use conf;
use AdFront;

&Main();

sub Main
{
	my $front = new AdFront( &conf::param( {} ) );

	$front->Init();

	$front->{ param }{ MAINCSS } = $front->{ param }{ ADDRESS } . '/' . $front->{ param }{ MAINCSS };
	$front->{ param }{ MDCSS } = $front->{ param }{ ADDRESS } . '/' . $front->{ param }{ MDCSS };

	$front->Out();
}
