package Plugin::Base::Plugin;

use strict;
use warnings;

sub new
{
	my ( $package ) = @_;

	return bless ( {}, $package );
}

sub Init()
{
	my ( $self, $pm ) = @_;
	$self->{ pm } = $pm;
	$pm->AddMDPlugin( "img", $self );
}

sub Omit()
{
	my ( $text, $max ) = ( @_ );
	my @line = split( /\n/, ${ $text }, $max + 1 );
	if ( $max <= scalar( @line ) ){ pop( @line ); }
	return join( "\n", @line );
}

sub Inline()
{
	my ( $self, @arg ) = ( @_ );

	my $name = $self->{ pm }->{ name };
	if ( $name eq 'img' )
	{
		return $self->Img( @arg );
	}

	return \( '' );
}

##########

sub Img()
{
	my ( $self, $file ) = ( @_ );

	my ( $path ) = $self->{ pm }->{ io }->GetCurrentDir();

	$path = $self->{ pm }->{ param }{ ADDRESS } . '/' . $self->{ pm }->{ param }{ UPLOAD } . '/' . $path . $file;

	$path = '<img src="' . $path . '" />';

	return \$path;
}

1;
