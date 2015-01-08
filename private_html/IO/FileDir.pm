package FileDir;

use strict;
use warnings;

sub new
{
	my ( $package, $param ) = @_;

	return bless ( { io => $param }, $package );
}

1;
