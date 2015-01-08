package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { io => $param }, $package );
}

sub loadmarkdown()
{
	my ( $self, $file ) = ( @_ );

	my $title = '';
	my $md = '';

	if ( open( MD, "< " . $self->{ io }->{ param }{ PUBDIR } . '/' . $file ) )
	{
		$title = $md = <MD>;
		while( <MD> )
		{
			$md .= $_;
		}
		close( MD );
	}

	return ( $title, \$md );
}

sub savemarkdown()
{
	my ( $self, $file, $md ) = ( @_ );

	if ( open( MD, "> " . $self->{ io }->{ param }{ PUBDIR } . '/' . $file ) )
	{
		print MD ${ $md };
		close( MD );
	}
}

sub loadfile()
{
	my ( $self, $file ) = ( @_ );
	my $txt = '';
	if ( open( FILE, "< $file" ) )
	{
		while( <FILE> )
		{
			$txt .= $_;
		}
		close( FILE );
	}
	return \$txt;
}

sub checkfiledir()
{
	my ( $self, $file ) = ( @_ );
	my $dir = '';
	if ( $file ne '' )
	{
		if ( -r $self->{ io }->{ param }{ PUBDIR } . '/' . $file . '.md')
		{
			$file .= '.md';
		} elsif ( -d $self->{ io }->{ param }{ PUBDIR } . '/' . $file )
		{
			$dir = $file;
			$file = '';
		} else
		{
			$file = '';
		}
	}
	return ( $file, $dir );
}

sub getblogdir()
{
	my ( $self, $dir ) = ( @_, '' );
	my @list;
	opendir( DIR, $self->{ io }->{ param }{ PUBDIR } . '/' . $self->{ io }->{ param }{ BLOG }  . '/' . $dir );
	foreach( readdir( DIR ) )
	{
		unless ( $_ =~ /^\./ ){ push( @list, $_ ); }
	}
	closedir( DIR );
	@list = sort{ $a cmp $b }( @list );
	return \@list;
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ io }->{ param }{ PUBDIR } . '/' . $dir;
	opendir( DIR, $basedir );
	my @list = readdir( DIR );
	closedir( DIR );

	my @dir;
	my @file;
	my $obj;
	while( scalar( @list ) )
	{
		$obj = shift( @list );
		if ( $obj =~ /^\./ ){ next; }
		if ( -d $basedir . '/' . $obj )
		{
			push( @dir, $obj . '/' );
		} else
		{
			if ( $obj =~ /(.+)\.md$/ ){ $obj = $1; }
			push( @file, $obj );
		}
	}

	return [ ( sort{ $a cmp $b }( @dir ) ), ( sort{ $a cmp $b }( @file ) ) ];
}

1;
