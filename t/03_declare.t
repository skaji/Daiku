use strict;
use warnings;
use utf8;
use Test::More;

use File::stat;
use t::Util;
use Daiku;
use Fatal;

my $tmpdir = tmpdir();

task 'all' => 'a.out';

task 'clean' => [], sub {
	unlink $_ for qw/b.o a.out c.o/;
};

file 'a.out' => ['b.o', 'c.o'] => sub {
	link_([qw/b.o c.o/] => 'a.out');
};

file 'b.o' => 'b.c' => sub {
	compile('b.c' => 'b.o');
};

file 'c.o' => 'c.c' => sub {
	compile('c.c' => 'c.o');
};

write_file("c.c", "c1");
write_file("b.c", "b1");
build('a.out');
my $c_o_mtime1 = stat('c.o')->mtime;
is(slurp('a.out'), "OBJ:b1\nOBJ:c1");
write_file("b.c", "b2");
build('b.o');
is(slurp('b.o'), "OBJ:b2");
is(slurp('a.out'), "OBJ:b1\nOBJ:c1");
build('a.out');
is(slurp('a.out'), "OBJ:b2\nOBJ:c1");
my $c_o_mtime2 = stat('c.o')->mtime;
is($c_o_mtime1, $c_o_mtime2, 'is not modified.');

done_testing;

