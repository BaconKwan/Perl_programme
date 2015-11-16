#! /usr/bin/perl

use utf8;
use strict;
use warnings;

open IN, "$ARGV[0]" || die $!;
<IN>;
while(<IN>){
	chomp;
	my @line = split /\t/;
	print "$line[0]\tprotein_coding\texon\t1\t$line[1]\t.\t+\t.\tgene_id \"$line[0]\"\; transcript_id \"$line[0]\"\;\n";
}
close IN;
