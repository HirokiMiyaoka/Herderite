package Blog;

sub new
{
	my ( $package, $param ) = ( @_ );
	return bless ( { param => $param }, $package );
}

sub dirs()
{
	my ( $self, $dir ) = ( @_, '' );
	my @list;
	opendir( DIR, $self->{ param }{ DIR } . '/' . $self->{ param }{ BLOG }  . '/' . $dir );
	foreach( readdir( DIR ) )
	{
		unless ( $_ =~ /^\./ ){ push( @list, $_ ); }
	}
	closedir( DIR );
	@list = sort{ $a cmp $b }( @list );
	return \@list;
}

sub list
{
	my ( $self, $y, $m, $d ) = ( @_ );

	my $out = '';
	my @y = reverse( @{ $self->dirs() } );

	$out = '<ul>';
	foreach ( @y )
	{
		if ( $_ eq $y )
		{
			$out .= '<li>' . $_;
			my @m = @{ $self->dirs( $y ) };
			$out .= '<ul>';
			foreach ( @m )
			{
				if ( $_ eq $m )
				{
					$out .= '<li>' . $_;
					my @d = @{ $self->dirs( $y . '/' . $m ) };
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
					$out . '</ul></li>';
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
