package conf;
sub param{return {
DL      => 1,
DIRLIST => 1,
TITLE   =>'Herderite',
CSS     => '',
JS      => '',
HOME    => '/',
ADDRESS => 'http://example.com/',
MAINCSS => 'style.css',
MDCSS   => 'mdstyle.css',
DEF     => 'index',
PUBDIR  => '../public_html',
PRIDIR  => '../private_html',
LIBDIR  => '../herderite',
BLOG    => 'blog',
HTTP    => ["Content-Type: text/html\n"],
DATAMAX => 50000000,
DEV     => '',
%{$_[0]}};}
1;
