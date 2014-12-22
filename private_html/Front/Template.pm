package Template;

use strict;
use warnings;
use URI::Escape;

sub new
{
	my ( $package, $param ) = ( @_ );
	return bless ( { param => $param }, $package );
}

sub header
{
	my ( $self ) = ( @_ );
	return '<a href="' . $self->{ param }{ HOME } . '" id="logo" title="Home"></a>';
}

sub footer
{
	return 'Powered by <a href="https://github.com/HirokiMiyaoka/Herderite" target="_blank" title="Herderite GithHub page.">Herderite</a> &copy; 2014 Hiroki';
}

sub breadcrumbs
{
	my ( $self, $file ) = ( @_ );
	my $path = $self->{ param }{ HOME } . '?f=';

	my @list = split( /\//, $file );

	if ( $list[ 0 ] eq '.' ){ shift( @list ); }
	if ( 0 < scalar( @list ) )
	{
		$file = uri_escape_utf8( pop( @list ) );
		#$file =~ s/(\.[^\.]+)$//;
	} else
	{
		$file = '';
	}

	foreach ( @list )
	{
		$path .= uri_escape_utf8( $_ ) . '%2f';
		$_ = '<a href="' . $path . '">' . $_ . '</a>';
	}

	unshift( @list, '<a href="' . $self->{ param }{ HOME } . '">Home</a>' );

	if ( $file ne '' ){ push( @list, $file ) }

	return join( ' / ', @list );
}

sub headmenu
{
	my ( $self ) = ( @_ );
	return '			<div id="head">' . $self->breadcrumbs( $self->{ param }{ file } ) . '</div>
';
}

sub footmenu
{
	return '			<div id="foot"></div>
';
}

sub sidemenu
{
	return '			<div id="side"></div>';
}

sub head
{
	my ( $self ) = ( @_ );

	return '<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=640,user-scalable=yes" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<link rel="shortcut icon" href="favicon.ico" type="image/vnd.microsoft.ico"/>
	<link rel="stylesheet" href="./style.css" type="text/css" />
	<link rel="stylesheet" href="./mdstyle.css" type="text/css" />
	<title>' . $self->{ param }{ TITLE } . '</title>
	<style>' . $self->{ param }{ CSS } . '</style>
	<script>' . $self->{ param }{ JS } . '</script>
</head>
<body>
	<div>
		<header>
' . $self->header() . '
		</header>
		<article>
' . $self->headmenu();
}

sub foot
{
	my ( $self ) = ( @_ );

	return $self->footmenu() . $self->sidemenu() . '
		</article>
		<footer>
' . $self->footer() . '
		</footer>
	</div>
</body>
</html>';
}

1;
