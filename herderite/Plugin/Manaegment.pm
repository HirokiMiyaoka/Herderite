package Manaegment;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $io ) = @_;

	return bless ( { param => $param, io => $io, mdbefore => [], mdafter => [], mdplugin => {} }, $package );
}

sub list()
{
	my ( $self ) = ( @_ );
	my @list;
	my $dir = $self->{ param }{ LIBDIR } . '/Plugin/';
	opendir( DIR, $dir );
	foreach ( readdir( DIR ) )
	{
		if ( $_ =~ /^\./ || -f $dir . $_ ){ next; }
		push( @list, $_ );
	}
	closedir( DIR );
	return \@list;
}

sub loadplugin()
{
	my ( $self ) = ( @_ );
	foreach( @{ $self->list() } )
	{
		my $class = 'Plugin::' . $_ . '::Plugin';
		eval( "use $class;" );
		if ( $@ ){ next; }
		my $obj = new $class;
		$obj->init( $self );
	}
}

sub addbeforemdparse()
{
	my ( $self, $obj ) = ( @_ );
	push( @{ $self->{ mdbefore } }, $obj );
}

sub addaftermdparse()
{
	my ( $self, $obj ) = ( @_ );
	push( @{ $self->{ mdafter } }, $obj );
}

sub addmdplugin()
{
	my ( $self, $name, $obj ) = ( @_ );
	$self->{ mdplugin }{ $name } = $obj;
}

sub rep()
{
	my $self = shift( @_ );
	my ( $plugin, @arg ) = split( / /, shift( @_ ) );
	unless ( exists( $self->{ mdplugin }{ $plugin } ) ){ return "<!-- $plugin not found -->"; }
	return ${ $self->{ mdplugin }{ $plugin }->inline( @arg ) };
}

sub mdplugin()
{
	my ( $self, $md ) = ( @_ );
	my $count = 50;
	while ( $md =~ s/(?:\{\{([^}]+)\}\})/$self->rep($1)/e ){ if( --$count <= 0 ){ last; } }
	return $md;
}

sub beforemdparse()
{
	my ( $self, $md ) = ( @_ );

	foreach( @{ $self->{ mdbefore } } )
	{
		$_->beforemdparse( $md );
	}
}

sub aftermdparse()
{
	my ( $self, $html ) = ( @_ );

	foreach( @{ $self->{ mdafter } } )
	{
		$_->aftermdparse( $html );
	}
}

1;
