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

sub init()
{
	my ( $self ) = ( @_ );

    $self->SUPER::init();

	unless ( exists( $self->{ io }->{ post }{ text } ) ){ $self->{ io }->{ post }{ text } = ''; }

	my $uri = $ENV{ 'REQUEST_URI' } || '';
	$uri =~ /([^\/]+)(?:\?.+)$/;
	$self->{ param }{ script } = $1 || './';
}

sub error
{
	my ( $self, $code ) = ( @_ );

	if ( $code != 404 )
	{
		$self->{ param }{ blog } = $self->{ plugin }{ tool };
		$self->{ param }{ TITLE } = 'Error - ' . $code;
		my $tmplate = new Template( $self->{ param }, $self->{ plugin } );
		return \( $tmplate->head() . $code . $tmplate->foot() );
	}

	$self->{ param }{ file } = $self->{ io }->{ get }{ f } . '.md';
	return $self->outhtml();
}

sub outhtml
{
	my ( $self ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );
	my $md = new Markdown( $self->{ param }, $self->{ io } );

	my $content = '';

	my $mdtxt = \'';
	my $title = "";

	if ( $self->{ io }->{ post }{ text } ne '' )
	{
		( $title ) = split( /\n/, $self->{ io }->{ post }{ text }, 2 );
		$content = ${ $md->outInMem( \$self->{ io }->{ post }{ text } ) };

		if ( exists( $self->{ io }->{ post }{ post } ) )
		{
			$self->{ io }->savemarkdown( $self->{ param }{ file }, \$self->{ io }->{ post }{ text } )
		}

	} else
	{
		( $title, $mdtxt ) = $self->{ io }->loadmarkdown( $self->{ param }{ file } );
		$content = ${ $md->outInMem( $mdtxt ) };
	}

	$title =~ s/^\#+ //;
	$title =~ s/[\r\n]//g;
	#$title =~ s/([^\\s]+)/$1/;
	if ( $title ne '' ){ $title .= ' - '; }

	$self->{ param }{ TITLE } = $title . $self->{ param }{ TITLE };

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	return \( $tmplate->head() . $self->form( \($self->{ io }->{ post }{ text } || ${ $mdtxt } ) ) . $content . $tmplate->foot() );
}

sub form()
{
	my ( $self, $md ) = ( @_ );
	return '<form style="margin:0.5em 0px;" required="required" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="post"><textarea style="width:98%;height:200px;margin:10px auto;display:block;" name="text" autofocus="autofocus">' . ${ $md } .
	'</textarea>' .
	'<input type="submit" name="preview" value="Preview" />' .
	($self->{ io }->{ post }{ text } eq '' ? '' : '<input type="submit" name="post" value="Post" />') .
	'</form><hr />';
}

1;
