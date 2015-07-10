package Plugin::Blog::Plugin;

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
	$pm->AddMDPlugin( "blog", $self );
	$pm->AddMDPlugin( "blogimg", $self );
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
	if ( $name eq 'blog' )
	{
		return $self->Blog( @arg );
	} elsif ( $name eq 'blogimg' )
	{
		return $self->BlogImg( @arg );
	}

	return \( '' );
}

##########

sub Blog()
{
	my ( $self, $count ) = ( @_, 1 );

	my $io = $self->{ pm }->{ io };
	my $pr = $self->{ pm }->{ param };

	my ( $y, $m, $d );
	my $ret = '';
	my $max = 10;
	foreach $y ( reverse( @{ $io->GetBlogDir() } ) )
	{
		foreach $m ( reverse( @{ $io->GetBlogDir( $y ) } ) )
		{
			foreach $d (reverse( @{ $io->GetBlogDir( $y . '/' . $m ) } ) )
			{
				my $tmp = $io->{ get }{ b };
				$io->{ get }{ b } = $y . $m . $d;
				my ( $title, $md ) = ( $io->LoadMarkdown( $pr->{ BLOG } . '/' . $y . '/' . $m . '/' . $d, $self->{ pm } ) );
				( $d ) = split( /\./, $d );
				$ret .= "----\n" . &Omit( $md, $max ) . '<p>...</p><div class="blogfoot"><a href="' . $pr->{ HOME } . '?b=' . $y . $m . $d . '">続きを読む</a></div>';
				$io->{ get }{ b } = $tmp;
				if( --$count <= 0 ){ return \$ret; }
			}
		}
	}

	return \$ret;
}

sub BlogImg()
{
	my ( $self, $file ) = ( @_ );

	my ( $path, $d ) = $self->{ pm }->{ io }->GetCurrentDir();

	$path = $self->{ pm }->{ param }{ ADDRESS } . '/' . $self->{ pm }->{ param }{ UPLOAD } . '/' . $path . '/' . $d . '/' . $file;

	$path = '<img src="' . $path . '" />';

	return \$path;
}

1;
