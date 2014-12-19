package Template;

use strict;
use warnings;

sub new
{
	my ( $package, $param ) = ( @_ );
	return bless ( { param => $param }, $package );
}

sub header
{
	return '';
}

sub footer
{
	return '';
}

sub headmenu
{
	return '			<div></div>
';
}

sub sidemenu
{
	return '			<div></div>';
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
	return $self->sidemenu() . '
		</article>
		<footer>
' . $self->footer() . '
		</footer>
	</div>
</body>
</html>';
}

1;
