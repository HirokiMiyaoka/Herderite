package AdFront;

use strict;
use warnings;

use Front;
our @ISA = qw( Front );

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub error
{
	my ( $self, $code ) = ( @_ );

	$self->{ param }{ blog } = $self->{ param }{ tool } = new Tool( $self->{ param } );

	$self->{ param }{ TITLE } = 'Error - ' . $code;
	my $tmplate = new Template( $self->{ param } );
	if ( $code != 404 )
	{
		return $tmplate->head() . $code . $tmplate->foot();
	}
	return $tmplate->head() . $self->form( \'' ) . $tmplate->foot();
}

sub outhtml
{
	my ( $self ) = ( @_ );

	$self->{ param }{ tool } = new Tool( $self->{ param } );
	$self->{ param }{ blog } = new Blog( $self->{ param } );

	my $content = '';

	my $mdtxt = '';
	my $title = "";
	if ( open( MD, "< " . $self->{ param }{ DIR } . '/' . $self->{ param }{ file } ) )
	{
		$title = $mdtxt = <MD>;
		$title =~ s/^\#+ //;
		$title =~ s/[\r\n]//g;
		#$title =~ s/([^\\s]+)/$1/;
		if ( $title ne '' ){ $title .= ' - '; }
		$mdtxt .= join( '', <MD> );
		close( MD );
	}
	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };

	my $md = new Markdown( $self->{ param } );
	$content = ${ $md->outInMem( \$mdtxt ) };

	my $tmplate = new Template( $self->{ param } );

	return $tmplate->head() . $self->form( \$mdtxt ) . $content . $tmplate->foot();
}

sub form()
{
	my ( $self, $md ) = ( @_ );
	return '<textarea>' . ${ $md } . '</textarea>';
}

1;
