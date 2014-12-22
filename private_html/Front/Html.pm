package Html;

use strict;
use warnings;

use lib '..';
use Front::Markdown;
use Front::Template;
use Front::Blog;

sub new
{
	my ( $package, $param, $get ) = @_;

	return bless ( { param => $param, get => $get }, $package );
}

sub error
{
	my ( $self, $code ) = ( @_ );
	$self->{ param }{ blog } = new Blog( $self->{ param } );
	$self->{ param }{ TITLE } = 'Error - ' . $code;
	my $tmplate = new Template( $self->{ param } );
	return $tmplate->head() . $code . $tmplate->foot();
}

sub out
{
	my ( $self ) = ( @_ );

	$self->{ param }{ blog } = new Blog( $self->{ param } );

	my $content = '';

	if ( -f $self->{ param }{ file } )
	{
		my $md = new Markdown( $self->{ param } );
		$content = ${ $md->out( $self->{ param }{ file } ) };
	}

	my $tmplate = new Template( $self->{ param } );

	return $tmplate->head() . $content . $tmplate->foot();
}

1;
