package conf;
sub param{return {
DL    => 1,
TITLE =>'Herderite',
CSS   => '',
JS    => '',
HOME  => '',
DEF   => 'index',
DIR   => '.',
BLOG  => 'blog',
HTTP  => ["Content-Type: text/html\n"],
DEV   => '',
%{$_[0]}};}
1;
