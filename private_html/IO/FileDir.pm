package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { io => $param }, $package );
}

sub getdirlist()
{
	my ( $self, $dir ) = ( @_ );

	my $basedir = $self->{ io }->{ param }{ DIR } . '/' . $dir;
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
		if ( -f $basedir . $obj )
		{
			if ( $obj =~ /(.+)\.md$/ ){ $obj = $1; }
			push( @file, $obj );
		} else
		{
			push( @dir, $obj . '/' );
		}
	}

	return [ sort{ $a cmp $b }( @dir ), sort{ $a cmp $b }( @file ) ];
}

1;
