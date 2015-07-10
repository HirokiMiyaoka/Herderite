package Markdown;

use strict;
use warnings;

use Text::Markdown 'markdown';

sub new
{
	my ( $package, $param, $io ) = @_;

	return bless ( { param => $param, io => $io }, $package );
}

sub Out
{
	my ( $self, $file, $plugin ) = ( @_ );

	my ( $title, $md ) = $self->{ io }->LoadMarkdown( $file, $plugin );

	$title =~ s/^\#+ //;
	$title =~ s/[\r\n]//g;
	#$title =~ s/([^\\s]+)/$1/;
	if ( $title ne '' ){ $title .= ' - '; }
	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };

	if ( $plugin ){ $plugin->BeforeMDParse( $md ); }

	my $html = &markdown( ${ $md } );

	return \$html;
}

sub OutInMem
{
	my ( $self, $md, $plugin ) = ( @_ );

	if ( $plugin )
	{
		my @line = split( /\n/, ${ $md } );
		foreach ( @line )
		{
			$_ = $plugin->MDPlugin( $_ );
		}
		my $html = &markdown( join( "\n", @line ) );
		return \$html;
	}

	my $html = &markdown( ${ $md } );
	return \$html;
}

1;
