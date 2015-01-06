package conf;
sub param{return {
DL      => 1,
TITLE   =>'Herderite',
CSS     => '',
JS      => '',
HOME    => '/',
ADDRESS => 'http://example.com/',
MAINCSS => 'style.css',
MDCSS   => 'mdstyle.css',
DEF     => 'index',
DIR     => '../public_html',
BLOG    => 'blog',
HTTP    => ["Content-Type: text/html\n"],
DEV     => '',
%{$_[0]}};}
1;
