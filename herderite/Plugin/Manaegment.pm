package Manaegment;

use strict;
use warnings;

sub new
{
	my ( $package, $param, $io ) = @_;

	return bless ( { param => $param, io => $io, name => '', mdbefore => [], mdafter => [], mdplugin => {} }, $package );
}

sub List()
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

sub LoadPlugin()
{
	my ( $self ) = ( @_ );
	foreach( @{ $self->List() } )
	{
		my $class = 'Plugin::' . $_ . '::Plugin';
		eval( "use $class;" );
		if ( $@ ){ next; }
		my $obj = new $class;
		$obj->Init( $self );
	}
}

sub AddBeforeMDParse()
{
	my ( $self, $obj ) = ( @_ );
	push( @{ $self->{ mdbefore } }, $obj );
}

sub AddAfterMDParse()
{
	my ( $self, $obj ) = ( @_ );
	push( @{ $self->{ mdafter } }, $obj );
}

sub AddMDPlugin()
{
	my ( $self, $name, $obj ) = ( @_ );
	$self->{ mdplugin }{ $name } = $obj;
}

sub Rep()
{
	my $self = shift( @_ );
	my ( $plugin, @arg ) = split( / /, shift( @_ ) );
	unless ( exists( $self->{ mdplugin }{ $plugin } ) ){ return "<!-- $plugin not found -->"; }
	$self->{ name } = $plugin;
	return ${ $self->{ mdplugin }{ $plugin }->Inline( @arg ) };
}

sub MDPlugin()
{
	my ( $self, $md ) = ( @_ );
	my $count = 50;
	while ( $md =~ s/(?:\{\{([^}]+)\}\})/$self->Rep($1)/e ){ if( --$count <= 0 ){ last; } }
	return $md;
}

sub BeforeMDParse()
{
	my ( $self, $md ) = ( @_ );

	foreach( @{ $self->{ mdbefore } } )
	{
		$_->BeforemDParse( $md );
	}
}

sub AfterMDParse()
{
	my ( $self, $html ) = ( @_ );

	foreach( @{ $self->{ mdafter } } )
	{
		$_->AfterMDParse( $html );
	}
}

1;
