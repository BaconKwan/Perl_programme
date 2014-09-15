#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	separate gff_file into 3 parts: fa, gff & head
	Usage: perl $0 <gff_file>

"if(@ARGV != 1);

open IN, $ARGV[0]  or die $!;
open OUTFA , '>' , $ARGV[0].".fa";
open OUTGFF , '>' , $ARGV[0].".gff";
open OUTHEAD , '>' , $ARGV[0].".head";

my $flag = 0;
my %hash;
my ($key, $value);

while(<IN>){
	($flag = 1) if (/^>/);
	if (0 == $flag){
		if (/^#/){
			print OUTHEAD $_;
		}else{
			$hash{$_} += 1;
		}
	}elsif (1 == $flag){
		print OUTFA $_;
	}
}

while (($key, $value) = each %hash){
	print OUTGFF $key;
}
#nohup perl test.pl &
