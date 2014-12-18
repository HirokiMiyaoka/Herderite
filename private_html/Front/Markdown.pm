package Markdown;

use strict;
use warnings;

use Text::Markdown 'markdown';

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub out()
{
	my ( $self, $file ) = ( @_ );

	my $md = '';
	my $title = "";
	if ( open( MD, "< $file" ) )
	{
		$title = $md = <MD>;
		$title =~ s/^\# //;
		$md .= join( '', <MD> );
		close( MD );
	}

	return { title => $title, html => &markdown( $md ) };
}

1;
