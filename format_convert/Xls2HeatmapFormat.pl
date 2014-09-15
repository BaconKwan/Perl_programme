#! /usr/bin/perl -w
use utf8;
use strict;

open IN , $ARGV[0];
open OUT , '>' , "$ARGV[0].HeatFormat";

my $head = 0;
my @elements;

while (<IN>){
	my $text = $_;
	my $flag = 0;
	@elements = split /\t/ , $text;
	if (0 == $head){
		$elements[1] =~ s/ /_/;
		$elements[4] =~ s/\w+\((\w+)\)/$1/;
		$elements[5] =~ s/\w+\((\w+)\)/$1/;
		$elements[6] =~ s/\w+\((\w+)\)/$1/;
		$elements[7] =~ s/\w+\((\w+)\)/$1/;
		$head = 1;
		$flag = 1;
	}
	else{
		if(((log(2**$elements[10]/2**$elements[11])/log(2)) > 1 && $elements[12] < 0.05) || ((log(2**$elements[10]/2**$elements[11])/log(2)) < -1 && $elements[12] < 0.05)){
			$elements[4] = 2**$elements[4];
			$elements[5] = 2**$elements[5];
			$elements[6] = 2**$elements[6];
			$elements[7] = 2**$elements[7];
			$flag = 1;
		}
	}
	print OUT "$elements[1]\t$elements[4]\t$elements[5]\t$elements[6]\t$elements[7]\n" if 1 == $flag;
}
