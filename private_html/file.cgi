#!/usr/bin/perl --

use strict;
use warnings;

use lib '../herderite';
use conf;

print &main();

sub main()
{
	my %conf = %{ &conf::param( {} ) };
	$conf{ DOCROOT } = $conf{ PUBDIR } . '/' . $conf{ UPLOAD } . '/';
	my %data = &analysis();

	if ( $data{ mode } eq 'remove' )
	{
	} else
	{
		my $pubpath = $conf{ ADDRESS } . '/' . $conf{ UPLOAD } . '/';
		&list( $conf{ DOCROOT } . $data{ path }, $pubpath );
	}
}

sub list()
{
	my ( $path, $pubpath ) = ( @_ );

	opendir( DIR, $path );
	my @list = readdir( DIR );
	closedir( DIR );
	unless ( $path =~ /\/$/ ){ $path .= '/'; }
	my $html = '<tr><td>File</td><td>Del</td></tr>';
	foreach ( @list )
	{
		if ( -f $path . $_ )
		{
			$html .= '<tr><td><a href="' . $pubpath . $_ . '" target="_blank">' . $_ . '</a></td><td>Del</td></tr>';
		}
	}

	return &html( \$html );
}

sub html()
{
	my $html = ${ $_[ 0 ] };
	return "Content-Length: " . length( $html ) . "\n\n" . $html;
}

sub analysis()
{
	my %data = %{ &CommonDecode( \( $ENV{ 'QUERY_STRING' } || '' ) ) };
	unless ( exists( $data{ path } ) ){ $data{ path } = ''; }
	unless ( exists( $data{ mode } ) ){ $data{ mode } = 'list'; }
	return %data;
}

sub CommonDecode
{
	my ( $query ) = ( @_ );
	my @args = split( /&/, ${ $query } );
	my %ret;
	foreach ( @args )
	{
		unless( $_ =~ /\=/ ){next;}
		my ( $name, $val ) = split( /=/, $_, 2 );
		$val =~ tr/+/ /;
		$val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
		unless ( exists ( $ret{ $name } ) )
		{
			$ret{ $name } = $val;
		} else
		{
			unless ( ref ( $ret{ $name } ) =~ /^ARRAY/ )
			{
				my $tmp = $ret{ $name };
				delete ( $ret{ $name } );
				$ret{ $name }[ 0 ] = $tmp;
			}
			push ( @{ $ret{$name} }, $val );
		}
	}

	return \%ret;
}
