package Tool;

use strict;
use warnings;

use URI::Escape;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub List{ return ''; }

sub Breadcrumbs
{
	my ( $self, $file ) = ( @_ );
	my $path = $self->{ param }{ HOME };

	my $sp = '';
	my $blog = '';

	my @list = split( /\//, $file );

	if ( 0 < scalar( @list ) && $list[ 0 ] eq '.' ){ shift( @list ); }
	if ( 0 < scalar( @list ) )
	{
		if ( $list[ 0 ] eq $self->{ param }{ BLOG } )
		{
			$path .= '?b=';
			$blog = shift( @list );
		} else
		{
			$path .= '?f=';
			$sp = '%2f';
		}
		$file = uri_escape_utf8( pop( @list ) );
		#$file =~ s/(\.[^\.]+)$//;
	} else
	{
		$file = '';
	}

	foreach ( @list )
	{
		$path .= uri_escape_utf8( $_ ) . $sp;
		$_ = '<a href="' . $path . '">' . $_ . '</a>';
	}

	if ( $blog ne '' )
	{
		unshift( @list, '<a href="' . $self->{ param }{ HOME } . '?b=blog">Blog</a>' );
	}
	unshift( @list, '<a href="' . $self->{ param }{ HOME } . '">Home</a>' );

	if ( $file ne '' ){ push( @list, $file ) }

	return join( ' / ', @list );
}

1;
