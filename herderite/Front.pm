package Front;

use strict;
use warnings;

use URI::Escape;

use HerderiteIO;
use Front::Markdown;
use Front::Template;
use Front::Blog;
use Front::Tool;
use Plugin::Manaegment;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { param => $param }, $package );
}

sub Init
{
	my ( $self ) = ( @_ );
	$self->{ io } = new HerderiteIO( $self->{ param } );
	$self->{ io }->GetDevice();
	$self->{ io }->Decode();
	$self->{ plugin } = {
		management => new Manaegment( $self->{ param }, $self->{ io } ),
		tool => new Tool( $self->{ param }, $self->{ io } ),
	};
	$self->{ plugin }{ management }->LoadPlugin();
	$self->{ param }{ mddate } = 1;
}

sub Out
{
	my ( $self ) = ( @_ );

	my ( $file, $dir ) = $self->{ io }->CheckFileDir( $self->{ io }->GetFileName() );

	$self->{ param }{ file } = $file;

	my $out;

	if ( $file ne '' )
	{
		$out = ${ $self->OutHtml() };
	} elsif( $self->{ param }{ DIRLIST } && $dir ne '' )
	{
		$out = ${ $self->DirList( $dir ) };
	} else
	{
		$out = ${ $self->Error( 404 ) };
	}

	if ( exists( $self->{ param }{ redirect } ) )
	{
		$self->Redirect( $self->{ param }{ redirect } );
		return ;
	}

	push( @{ $self->{ param }{ HTTP } }, "Content-Length: " . length( $out ) . "\n" );

	print @{ $self->{ param }{ HTTP } };
	print "\n";
	print $out;
}

sub Redirect()
{
	my ( $self, $path ) = ( @_ );
	print 'Location:' . ( $self->{ param }{ ADDRESS } . $path ) . "\n\n";
	exit( 0 );
}

sub Error
{
	my ( $self, $code ) = ( @_ );

	$self->{ plugin }{ blog } = $self->{ plugin }{ tool };

	$self->{ param }{ TITLE } = 'Error - ' . $code;
	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );
	return \( $tmplate->Head() . $code . $tmplate->Foot() );
}

sub DirList
{
	my ( $self, $dir ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );

	$dir = $self->{ io }->GetDirPath( $dir );

	my $path = $self->{ param }{ HOME } . '?f=';
	my $basedir = $self->{ param }{ PUBDIR } . '/' . $dir;

	my @list = @{ $self->{ io }->GetDirList( $dir ) };

	my $content = '<h1>' . $dir . '</h1>' . '<ul>';

	my $parent = $self->{ io }->GetParentDirPath( $dir );

	my $bdir = $self->{ param }{ BLOG };
	if ( $dir =~ /^$bdir\/(.+)$/ )
	{
		$bdir = $1;
		$bdir =~ s/[^0-9]+//g;
		$path = $self->{ param }{ HOME } . '?b=';

		if ( $parent ne '' || $dir ne './' )
		{
			$content .= '<li><a href="' . $path . 'blog">' . '../' . '</a></li>';
		}

		foreach( @list )
		{
			my $n = $_;
			if ( -f $basedir . $_ && $_ =~ /(.+)\.md$/)
			{
				$n = $_ = $1;
			} elsif( $_ =~ /([0-9]+)\// )
			{
				$n = $1;
			}
			$content .= '<li><a href="' . $path . $bdir . $n . '">' . $_ . '</a></li>';
		}
	} else
	{
		if ( $parent ne '' || $dir ne './' )
		{
			$content .= '<li><a href="' . $path . uri_escape_utf8( $parent ) . '">' . '../' . '</a></li>';
		}

		foreach( @list )
		{
			if ( -f $basedir . $_ && $_ =~ /(.+)\.md$/)
			{
				$_ = $1;
			}
			$content .= '<li><a href="' . $path . uri_escape_utf8( $dir . $_ ) . '">' . $_ . '</a></li>';
		}
	}

	$content .= '</ul>';

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	return \( $tmplate->Head() . $content . $tmplate->Foot() );
}

sub OutHtml
{
	my ( $self ) = ( @_ );

	$self->{ plugin }{ blog } = new Blog( $self->{ param }, $self->{ io } );

	my $content = '';

	if ( -f $self->{ param }{ file } )
	{
		my $md = new Markdown( $self->{ param }, $self->{ io } );
		$content = ${ $md->Out( $self->{ param }{ file }, $self->{ plugin }{ management } ) };
	}

	$self->{ plugin }{ management }->AfterMDParse( \$content );

	my $tmplate = new Template( $self->{ param }, $self->{ plugin } );

	return \( $tmplate->Head() . $content . $tmplate->Foot() );
}

1;
