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
	my ( $self, $m ) = @_;
	$self->{ m } = $m;
	$m->addmdplugin( "blog", $self );
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
	my ( $self, $count ) = ( @_, 1 );

	my $io = $self->{ m }->{ io };
	my $pr = $self->{ m }->{ param };

	my ( $y, $m, $d );
	my $ret = '';
	my $max = 10;
	foreach $y ( reverse( @{ $io->getblogdir() } ) )
	{
		foreach $m ( reverse( @{ $io->getblogdir( $y ) } ) )
		{
			foreach $d (reverse( @{ $io->getblogdir( $y . '/' . $m ) } ) )
			{
				my ( $title, $md ) = ( $io->loadmarkdown( $pr->{ BLOG } . '/' . $y . '/' . $m . '/' . $d, $self->{ m } ) );
				( $d ) = split( /\./, $d );
				$ret .= "----\n" . &omit( $md, $max ) . '<div class="blogfoot"><a href="' . $pr->{ HOME } . '?b=' . $y . $m . $d . '">続きを読む</a></div>';
				if( --$count <= 0 ){ return \$ret; }
			}
		}
	}

	return \$ret;
}

1;
