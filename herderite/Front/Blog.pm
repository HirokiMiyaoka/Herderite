package Blog;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $io ) = ( @_ );
	return bless ( { param => $param, io => $io }, $package );
}

sub list
{
	my ( $self, $y, $m, $d ) = ( @_ );

	my $out = '';
	my @y = reverse( @{ $self->{ io }->getblogdir() } );

	$out = '<ul>';
	foreach ( @y )
	{
		if ( $_ eq $y )
		{
			$out .= '<li>' . $_;
			my @m = @{ $self->{ io }->getblogdir( $y ) };
			$out .= '<ul>';
			foreach ( @m )
			{
				if ( $_ eq $m )
				{
					$out .= '<li>' . $_;
					my @d = @{ $self->{ io }->getblogdir( $y . '/' . $m ) };
					$out .= '<ul>';
					foreach ( @d )
					{
						( $_ ) = split( /\./, $_ );
						if ( $_ eq $d )
						{
							$out .= '<li>' . $_ . '</li>';
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
