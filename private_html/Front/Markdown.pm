package Markdown;

use strict;
use warnings;

use Text::Markdown 'markdown';

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub out
{
	my ( $self, $file ) = ( @_ );

	my $md = '';
	my $title = "";
	if ( open( MD, "< $file" ) )
	{
		$title = $md = <MD>;
		$title =~ s/^\#+ //;
		$title =~ s/[\r\n]//g;
		#$title =~ s/([^\\s]+)/$1/;
		if ( $title ne '' ){ $title .= ' - '; }
		$md .= join( '', <MD> );
		close( MD );
	}
	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };
	my $html = &markdown( $md );
	return \$html;
}

1;
