package Plugin::Blog::Plugin;

use strict;
use warnings;

sub new
{
	my ( $package ) = @_;

	return bless ( {}, $package );
}

sub init()
{
	my ( $self, $pm ) = @_;
	$self->{ pm } = $pm;
	$pm->addmdplugin( "blog", $self );
	$pm->addmdplugin( "blogimg", $self );
}

sub omit()
{
	my ( $text, $max ) = ( @_ );
	my @line = split( /\n/, ${ $text }, $max + 1 );
	if ( $max <= scalar( @line ) ){ pop( @line ); }
	return join( "\n", @line );
}

sub inline()
{
	my ( $self, @arg ) = ( @_ );

	my $name = $self->{ pm }->{ name };
	if ( $name eq 'blog' )
	{
		return $self->blog( @arg );
	} elsif ( $name eq 'blogimg' )
	{
		return $self->blogimg( @arg );
	}

	return \( '' );
}

##########

sub blog()
{
	my ( $self, $count ) = ( @_, 1 );

	my $io = $self->{ pm }->{ io };
	my $pr = $self->{ pm }->{ param };

	my ( $y, $m, $d );
	my $ret = '';
	my $max = 10;
	foreach $y ( reverse( @{ $io->getblogdir() } ) )
	{
		foreach $m ( reverse( @{ $io->getblogdir( $y ) } ) )
		{
			foreach $d (reverse( @{ $io->getblogdir( $y . '/' . $m ) } ) )
			{
				my $tmp = $io->{ get }{ b };
				$io->{ get }{ b } = $y . $m . $d;
				my ( $title, $md ) = ( $io->loadmarkdown( $pr->{ BLOG } . '/' . $y . '/' . $m . '/' . $d, $self->{ pm } ) );
				( $d ) = split( /\./, $d );
				$ret .= "----\n" . &omit( $md, $max ) . '<div class="blogfoot"><a href="' . $pr->{ HOME } . '?b=' . $y . $m . $d . '">続きを読む</a></div>';
				$io->{ get }{ b } = $tmp;
				if( --$count <= 0 ){ return \$ret; }
			}
		}
	}

	return \$ret;
}

sub blogimg()
{
	my ( $self, $file ) = ( @_ );

	my ( $path, $d ) = $self->{ pm }->{ io }->getcurrentdir();

	$path = $self->{ pm }->{ param }{ ADDRESS } . '/' . $self->{ pm }->{ param }{ UPLOAD } . '/' . $path . '/' . $d . '/' . $file;

	$path = '<img src="' . $path . '" />';

	return \$path;
}

1;
