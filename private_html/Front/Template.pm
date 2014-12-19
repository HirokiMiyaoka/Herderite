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
	my ( $self ) = ( @_ );

	return '<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=640,user-scalable=yes" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<link rel="shortcut icon" href="favicon.ico" type="image/vnd.microsoft.ico"/>
	<link rel="stylesheet" href="./style.css" type="text/css" />
	<title>' . $self->{ param }{ TITLE } . '</title>
	<style>' . $self->{ param }{ CSS } . '</style>
	<script>' . $self->{ param }{ JS } . '</script>
</head>
<body>
	<header></header>
	<article>
';
}

sub footer
{
	return '
	</article>
	<footer></footer>
</body>
</html>';
}

1;
