package Markdown;

use Text::Markdown 'markdown';

sub new
{
	my ( $package ) = @_;

	return bless ( {}, $package );
}

sub out()
{
	my ( $self, $file ) = ( @_ );

	my $md = '';
	my $title = '';
	if ( open( MD, $file ) )
	{
		$tite = <MD>;
		$md = join('',<MD>);
		close( MD );
	}

	return { title => $title, html => &markdown( $md ) };
}

1;
