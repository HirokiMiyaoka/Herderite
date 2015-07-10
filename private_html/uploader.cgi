#!/usr/bin/perl --

use strict;
use warnings;

use lib '../herderite';
use conf;
use CGI;

print &Main();

sub Main()
{
	my %conf = %{ &conf::param( {} ) };
	$conf{ DOCROOT } = $conf{ PUBDIR } . '/' . $conf{ UPLOAD } . '/';
	$conf{ DIRPARMISIION } = 0705;
	my $query = new CGI;

	my $ref = &Decode( $query->param( 'ref' ) );

	my $upfile = ( $query->param( 'upfile' ) );

	# File size check.
	if ( $conf{ DATAMAX } > 0 )
	{
		my ( @state ) = stat( $upfile );
		if ( $conf{ DATAMAX } < $state[ 7 ] ){ return &Error( $ref, sprintf( 'File size over(max:%dB).', $conf{ DATAMAX } ) ); }
	}

	# Path check.
	my $path = &Decode( $query->param( 'path' ) );
	if ( $path =~ /\.\./ || $path =~ /^(\/)/ ){ return &Error( $ref, 'Upload path error.' ); }
	if ( $path eq '' ){ $path = './'; }

	if ( !( $upfile ) || $upfile =~ /(\/)$/ ){ return &Error( $ref, sprintf( 'File name illegal.(%s)', ($upfile?$upfile:'nofile') ) ); }

	# Directory check & create filepath;
	unless ( -d $conf{ DOCROOT } . $path )
	{
		my $name;
		my ( @el ) = split( /\//, $path );

		if ( $path =~ /(\/)$/ )
		{
			# Path is directory.
			$name = &Decode( $upfile );
		} else
		{
			# Path is filepath.
			$name = pop( @el );
		}

		# Make directory.
		$path = '/';#shift( @el ) . '/';
		foreach ( @el )
		{
			unless ( -d $conf{ DOCROOT } . $path . $_ ){ mkdir( $conf{ DOCROOT } . $path . $_, $conf{ DIRPARMISIION } ); }
			$path .= $_ . '/';
		}

		$path .= $name;
	} else
	{
		my ( $name ) = ( &Decode( $upfile ), '' );
		$path .= ( ($path =~ /(\/)$/) ? '' : '/' ) . $name;
	}

	$path = $conf{ DOCROOT } . $path;

	# File copy.
	if ( !($upfile) || &CopyFile( $path, $upfile ) ){ return &Error( $ref, sprintf( 'Cannot create file.(%s)', $path ) ); }

	close( $upfile );

	return &Success( $ref );
}

sub CopyFile()
{
	my ( $path, $upfile ) = ( @_ );
	my $buffer;

	if ( open( OUT, ">$path" ) )
	{
		binmode( OUT );
		while( read( $upfile, $buffer, 1024 ) )
		{
			print OUT $buffer;
		}
		close( OUT );
		return 0;
	}
	return 1;
}

sub Redirect()
{
	return sprintf( 'Location: %s', $_[ 0 ] ) . "\n\n";
}

sub Success()
{
	my ( $ref ) = ( @_ );
	if ( $ref ) { return &Redirect( $ref ); }
	return sprintf( '%s{"result":"success"}', 'Content-Type: application/json; charset=utf-8' . "\n\n" );
}

sub Error()
{
	my ( $ref, $msg ) = ( @_ );
	if ( $ref ) { return &Redirect( $ref ); }
	return sprintf( '%s{"result":"failure","msg":"%s"}', 'Content-Type: application/json; charset=utf-8' . "\n\n", $msg );
}

sub Decode()
{
	my ( $val ) = ( @_, "" );
	$val =~ tr/+/ /;
	$val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
	return $val;
}
