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
	$pm->AddMDPlugin( "category", $self );
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
	} elsif ( $name eq 'category' )
	{
		return $self->Category( @arg );
	}

	return \( '' );
}

##########

sub Img()
{
	my ( $self, $file ) = ( @_ );

	my ( $path ) = $self->{ pm }->{ io }->GetFileName();

	if ( $path =~ /\/index$/ || $path eq 'index' ){ ( $path ) = $self->{ pm }->{ io }->GetCurrentDir(); }

	$path = $self->{ pm }->{ param }{ ADDRESS } . '/' . $self->{ pm }->{ param }{ UPLOAD } . '/' . $path . '/' . $file;

	$path = '<img src="' . $path . '" />';

	return \$path;
}

sub Category()
{
	my ( $self, @arg ) = ( @_ );

	my @cate;

	foreach ( @arg ){ push( @cate, split( /,/, $_ ) ); }

	my $bhead = $self->{ pm }->{ param }{ BLOG } . '/';
	foreach ( @cate )
	{
		$_ = '<a href="' . $self->{ pm }->{ param }{ HOME } . '?c=' . $_ . '">' . $_ . '</a>';
	}

	my $cate = '<div class="category">[ ' . join( ' , ', @cate ) . ' ]</div>';

	return \$cate;
}

1;
