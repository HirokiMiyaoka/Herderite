package Html;

use strict;
use warnings;

use lib '..';
use Front::Markdown;

sub new
{
	my ( $package, $param, $get ) = @_;

	return bless ( { param => $param, get => $get }, $package );
}

sub out()
{
	my ( $self ) = ( @_ );

	my $md = new Markdown( $self->{ param } );
	my %content = %{ $md->out( $self->{ param }{ file } ) };

	return '<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=640,user-scalable=yes" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<link rel="shortcut icon" href="favicon.ico" type="image/vnd.microsoft.ico"/>
	<link rel="stylesheet" href="./style.css" type="text/css" />
	<title>' . $content{ title } . '</title>
	<style>
	</style>
	<script></script>
</head>
<body>
<article>
' . $content{ html } . '
</article>
</body>
</html>';
}

1;
