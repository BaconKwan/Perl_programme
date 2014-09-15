#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	generate combination between sampls in RNAsew pipeline
	Usage: perl $0 <input.lib>

"if(@ARGV != 1);

my @tags;
my @out;

while (<>){	
	push(@tags, $1) if (/label\s+=\s+(\w+)/);
}
for(my $i = 0; $i <= $#tags; $i++){
	for(my $j = $i + 1; $j <= $#tags; $j++){
		push(@out, "$tags[$i]&$tags[$j]");
	}
}
my $output = join ";", @out;

print "$output\n";
