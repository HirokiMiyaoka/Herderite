package Markdown;

use strict;
use warnings;

use Text::Markdown 'markdown';

sub new
{
	my ( $package, $param, $io ) = @_;

	return bless ( { param => $param, io => $io }, $package );
}

sub out
{
	my ( $self, $file ) = ( @_ );

	my ( $title, $md ) = $self->{ io }->loadmarkdown( $file );

	$title =~ s/^\#+ //;
	$title =~ s/[\r\n]//g;
	#$title =~ s/([^\\s]+)/$1/;
	if ( $title ne '' ){ $title .= ' - '; }

	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };
	my $html = &markdown( ${ $md } );

	return \$html;
}

sub outInMem
{
	my ( $self, $md ) = ( @_ );

	my $html = &markdown( ${ $md } );
	return \$html;
}

1;
