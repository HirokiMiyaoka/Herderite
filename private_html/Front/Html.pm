package Html;

use strict;
use warnings;

use lib '..';
use Front::Markdown;
use Front::Template;

sub new
{
	my ( $package, $param, $get ) = @_;

	return bless ( { param => $param, get => $get }, $package );
}

sub error
{
	my ( $self, $code ) = ( @_ );
	$self->{ param }{ TITLE } = 'Error - ' . $code;
	my $tmplate = new Template( $self->{ param } );
	return $tmplate->head() . $code . $tmplate->foot();
}

sub out
{
	my ( $self ) = ( @_ );

	my $md = new Markdown( $self->{ param } );
	my $content = ${ $md->out( $self->{ param }{ file } ) };

	my $tmplate = new Template( $self->{ param } );

	return $tmplate->head() . $content . $tmplate->foot();
}

1;
