package AdFront;

use strict;
use warnings;

use URI::Escape;

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

	$self->{ io }->writemode();
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

sub dirlist
{
	my ( $self, $dir ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );

	$dir = $self->{ io }->getdirpath( $dir );

	my $path = $self->{ param }{ HOME } . '?f=';
	my $basedir = $self->{ param }{ PUBDIR } . '/' . $dir;

	if ( exists( $self->{ io }->{ post }{ d } ) && $self->{ io }->{ post }{ d } ne '' )
	{
		mkdir( $basedir . $self->{ io }->{ post }{ d }, 0705 ); #TODO: moev FileIO
	}

	my @list = @{ $self->{ io }->getdirlist( $dir ) };

	my $content = '<h1>' . $dir . '</h1><ul>';

	my $parent = $self->{ io }->getparentdirpath( $dir );
	if ( $parent ne '' || $dir ne './' )
	{
		$content .= '<li><a href="' . $path . ( $parent eq '' ? '.' : uri_escape_utf8( $parent )) . '">' . '../' . '</a></li>';
	}

	foreach( @list )
	{
		if ( -f $basedir . $_ && $_ =~ /(.+)\.md$/)
		{
			$_ = $1;
		}
		$content .= '<li><a href="' . $path .uri_escape_utf8( $dir . $_ ) . '">' . $_ . '</a></li>';
	}

	$content .= '</ul>';

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	my $newblog = $self->{ param }{ BLOG };
	if ( $dir =~ /^(\.\/){0,1}$newblog\/$/ )
	{
		my ( @t ) = localtime( time() ); #TODO: param->time.
		$newblog = '<form style="float:right;margin:5px;" action="' .
		$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
		'" method="get"><input type="hidden" name="b" value="' .
		sprintf( '%4d%02d%02d', $t[ 5 ] + 1900, $t[ 4 ] + 1, $t[ 3 ] ) .
		'" /><input type="submit" value="Blog post" /></form>';
	} else{ $newblog = ''; }

	return \( $tmplate->head() .
	'<div style="height:1em;">' .
	$newblog .
	'<form style="float:right;margin:5px;" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="post"><input type="text" name="d" /><input type="submit" value="Create dir" /></form>' .
	'<form style="float:right;margin:5px;" action="' .
	$self->{ param }{ script } . '?' . ( $ENV{ 'QUERY_STRING' } || '' ) .
	'" method="get"><input type="text" name="f" /><input type="submit" value="Create page" /></form></div>' .
	$content . $tmplate->foot() );
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
			$self->{ io }->savemarkdown( $self->{ param }{ file }, \$self->{ io }->{ post }{ text } );
			# TODO: write check.
			my $tmp = $self->{ io }->{ post }{ text };
			$mdtxt = \$tmp;
			$self->{ io }->{ post }{ text } = '';
		}

	} else
	{
		( $title, $mdtxt ) = $self->{ io }->loadmarkdown( $self->{ param }{ file } );
		$content = ${ $md->outInMem( $mdtxt, $self->{ plugin }{ management } ) };
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
