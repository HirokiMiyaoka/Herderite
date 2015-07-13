package Template;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $plugin ) = ( @_ );
	${ $param }{ CSS } = '';
	${ $param }{ JS } = '';
	return bless ( { param => $param, plugin => $plugin }, $package );
}

sub Header
{
	my ( $self ) = ( @_ );
	return '<a href="' . $self->{ param }{ HOME } . '" id="logo" title="Home"><ul><li></li></ul></a>';
}

sub Footer
{
	my ( $self ) = ( @_ );
	return $self->{ param }{ CPYRIGHT } . ' Powered by <a href="https://github.com/HirokiMiyaoka/Herderite" target="_blank" title="Herderite GithHub page.">Herderite</a>';
}

sub Headmenu
{
	my ( $self ) = ( @_ );
	return '			<div id="head">' . $self->{ plugin }{ tool }->Breadcrumbs( $self->{ param }{ file } ) . '</div>
';
}

sub Footmenu
{
	return '			<div id="foot"></div>
';
}

sub Sidemenu
{
	my ( $self ) = ( @_ );
	return '			<div id="side">' . $self->{ plugin }{ blog }->List( $self->{ param }{ Y }, $self->{ param }{ M }, $self->{ param }{ D } ) . '</div>';
}

sub Head
{
	my ( $self ) = ( @_ );

	return '<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8" />
	<script type="text/javascript">ismobile=(function IsMobile(){var ua=window.navigator.userAgent.toLowerCase();return ((ua.indexOf("android")>0&&ua.indexOf("Mobile")>0)||ua.indexOf("ipod")>0||ua.indexOf("iphone")>0||ua.indexOf("mobile")>0);})();if(ismobile){document.write("<meta name=\"viewport\" content=\"width=640\" />");}</script>
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
		<header>' . $self->Header() . '<ul>
		</ul></header>
		<div>
			<article>
' . $self->HeadMenu();
}

sub Foot
{
	my ( $self ) = ( @_ );

	return $self->FootMenu() .
		'			</article>
' .
		$self->SideMenu() .
		'
		</div>
		<footer>' . $self->Footer() . '</footer>
	</div>
	<script>if(ismobile){(document.getElementsByTagName("body"))[0].classList.add("sp");}</script>
</body>
</html>';
}

1;
