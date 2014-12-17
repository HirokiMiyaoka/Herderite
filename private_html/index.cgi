#!/usr/bin/perl

use strict;
use warnings;

use Text::Markdown;

&Main();

sub Main()
{
	my %param = %{ &conf::param({DIR=>'../public_html'}) };

}
