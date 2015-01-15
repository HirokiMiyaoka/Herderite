package Template;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $plugin ) = ( @_ );
	return bless ( { param => $param, plugin => $plugin }, $package );
}

sub header
{
	my ( $self ) = ( @_ );
	return '<a href="' . $self->{ param }{ HOME } . '" id="logo" title="Home"></a>';
}

sub footer
{
	my ( $self ) = ( @_ );
	return $self->{ param }{ CPYRIGHT } . ' Powered by <a href="https://github.com/HirokiMiyaoka/Herderite" target="_blank" title="Herderite GithHub page.">Herderite</a> &copy; 2014 Hiroki';
}

sub headmenu
{
	my ( $self ) = ( @_ );
	return '			<div id="head">' . $self->{ plugin }{ tool }->breadcrumbs( $self->{ param }{ file } ) . '</div>
';
}

sub footmenu
{
	return '			<div id="foot"></div>
';
}

sub sidemenu
{
	my ( $self ) = ( @_ );
	return '			<div id="side">' . $self->{ plugin }{ blog }->list( $self->{ param }{ Y }, $self->{ param }{ M }, $self->{ param }{ D } ) . '</div>';
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
	<link rel="icon" href="favicon.ico" />
	<link rel="stylesheet" href="' . $self->{ param }{ MAINCSS } . '" type="text/css" />
	<link rel="stylesheet" href="' . $self->{ param }{ MDCSS } . '" type="text/css" />
	<title>' . $self->{ param }{ TITLE } . '</title>
	<style>' . $self->{ param }{ CSS } . '</style>
	<script>' . $self->{ param }{ JS } . '</script>
</head>
<body>
	<div>
		<header>' . $self->header() . '</header>
		<div>
			<article>
' . $self->headmenu();
}

sub foot
{
	my ( $self ) = ( @_ );

	return $self->footmenu() .
		'			</article>' .
		$self->sidemenu() .
		'		</div>
		<footer>' . $self->footer() . '</footer>
	</div>
</body>
</html>';
}

1;
