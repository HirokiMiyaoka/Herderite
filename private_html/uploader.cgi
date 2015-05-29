#!/usr/bin/perl --

use strict;
use warnings;

use lib '../herderite';
use conf;
use CGI;

print &main();

sub main()
{
	my %conf = %{ &conf::param( {} ) };
	$conf{ DOCROOT } = $conf{ PUBDIR } . '/' . $conf{ UPLOAD } . '/';
	$conf{ DIRPARMISIION } = 0705;
	my $query = new CGI;

	my $ref = &decode( $query->param( 'ref' ) );

	my $upfile = ( $query->param( 'upfile' ) );

	# File size check.
	if ( $conf{ DATAMAX } > 0 )
	{
		my ( @state ) = stat( $upfile );
		if ( $conf{ DATAMAX } < $state[ 7 ] ){ return &error( $ref, sprintf( 'File size over(max:%dB).', $conf{ DATAMAX } ) ); }
	}

	# Path check.
	my $path = &decode( $query->param( 'path' ) );
	if ( $path =~ /\.\./ || $path =~ /^(\/)/ ){ return &error( $ref, 'Upload path error.' ); }
	if ( $path eq '' ){ $path = './'; }

	if ( !( $upfile ) || $upfile =~ /(\/)$/ ){ return &error( $ref, sprintf( 'File name illegal.(%s)', ($upfile?$upfile:'nofile') ) ); }

	# Directory check & create filepath;
	unless ( -d $conf{ DOCROOT } . $path )
	{
		my $name;
		my ( @el ) = split( /\//, $path );

		if ( $path =~ /(\/)$/ )
		{
			# Path is directory.
			$name = &decode( $upfile );
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
		my ( $name ) = ( &decode( $upfile ), '' );
		$path .= ( ($path =~ /(\/)$/) ? '' : '/' ) . $name;
	}

	$path = $conf{ DOCROOT } . $path;

	# File copy.
	if ( !($upfile) || &copyfile( $path, $upfile ) ){ return &error( $ref, sprintf( 'Cannot create file.(%s)', $path ) ); }

	close( $upfile );

	return &success( $ref );
}

sub copyfile()
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

sub redirect()
{
	return sprintf( 'Location: %s', $_[ 0 ] ) . "\n\n";
}

sub success()
{
	my ( $ref ) = ( @_ );
	if ( $ref ) { return &redirect( $ref ); }
	return sprintf( '%s{"result":"success"}', 'Content-Type: application/json; charset=utf-8' . "\n\n" );
}

sub error()
{
	my ( $ref, $msg ) = ( @_ );
	if ( $ref ) { return &redirect( $ref ); }
	return sprintf( '%s{"result":"failure","msg":"%s"}', 'Content-Type: application/json; charset=utf-8' . "\n\n", $msg );
}

sub decode()
{
	my ( $val ) = ( @_, "" );
	$val =~ tr/+/ /;
	$val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
	return $val;
}
