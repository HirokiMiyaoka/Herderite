package Blog;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $io ) = ( @_ );
	return bless ( { param => $param, io => $io }, $package );
}

sub List
{
	my ( $self, $y, $m, $d ) = ( @_ );

	my $out = '';
	my @y = reverse( @{ $self->{ io }->GetBlogDir() } );

	$out = '<h2><a href="' . $self->{ param }{ HOME } . '?b=blog">Blog</a></h2><ul>';
	foreach ( @y )
	{
		if ( $_ eq $y )
		{
			$out .= '<li>' . $_;
			my @m = reverse( @{ $self->{ io }->GetBlogDir( $y ) } );
			$out .= '<ul>';
			foreach ( @m )
			{
				if ( $_ eq $m )
				{
					$out .= '<li>' . $_;
					my @d = reverse( @{ $self->{ io }->GetBlogDir( $y . '/' . $m ) } );
					$out .= '<ul>';
					foreach ( @d )
					{
						( $_ ) = split( /\./, $_ );
						if ( $_ eq $d )
						{
							$out .= '<li><a href="' . $self->{ param }{ HOME } . '?b=' . $y . $m . $_ . '"><b>' . $_ . '</b></a></li>';
						} else
						{
							$out .= '<li><a href="' . $self->{ param }{ HOME } . '?b=' . $y . $m . $_ . '">' . $_ . '</a></li>';
						}
					}
					$out .= '</ul></li>';
				} else
				{
					$out .= '<li><a href="' . $self->{ param }{ HOME } . '?b=' . $y . $_ . '">' . $_ . '</a></li>';
				}
			}
			$out .= '</ul></li>';

		} else
		{
			$out .= '<li><a href="' . $self->{ param }{ HOME } . '?b=' . $_ . '">' . $_ . '</a></li>';
		}
	}
	$out .= '</ul>';

	return $out;
}

1;
