#!/usr/bin/perl --

use strict;
use warnings;

use lib '../herderite';
use conf;

print &Main();

sub Main()
{
	my %conf = %{ &conf::param( {} ) };
	$conf{ DOCROOT } = $conf{ PUBDIR } . '/' . $conf{ UPLOAD } . '/';
	my %data = &Analysis();

	if ( $data{ mode } eq 'remove' )
	{
		return &Remove( $conf{ DOCROOT } . $data{ path }, $conf{ ADDRESS } );
	}
	my $pubpath = $conf{ ADDRESS } . '/' . $conf{ UPLOAD } . '/';

	return &List( $conf{ DOCROOT }, $data{ path }, $pubpath );
}

sub Remove()
{
	my ( $file, $ad  ) = ( @_ );
	if ( -f $file ){ unlink( $file ); }
	return 'Location: ' . ( $ENV{ HTTP_REFERER } || $ad ) . "\n\n";
}

sub List()
{
	my ( $doc, $path, $pubpath ) = ( @_ );

	unless ( $path =~ /\/$/ ){ $path .= '/'; }
	my $base = $doc . $path;
	opendir( DIR, $base );
	my @list = readdir( DIR );
	closedir( DIR );
	my $html = '<tr><td>File</td><td>Del</td></tr>';
	foreach ( @list )
	{
		if ( -f $base . '/' . $_ )
		{
			$html .= '<tr><td><a href="' . $pubpath . $_ . '" target="_blank">' . $_ . '</a></td><td>' .
				'<a href="file.cgi?mode=remove&path=' . $path . $_ . '">Del</a></td></tr>';
		}
	}

	return &Html( \$html );
}

sub Html()
{
	my $html = ${ $_[ 0 ] };
	return "Content-Length: " . length( $html ) . "\n\n" . $html;
}

sub Analysis()
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
