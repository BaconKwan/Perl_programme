#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die
"
	fetch sequence in fasta files according genelist
	Usage: perl $0 <genelist_file> <fasta_file>

"if(@ARGV != 2);

my %hash;
my @arr;

open LIST, "$ARGV[0]" || die $!;
while(<LIST>){
	chomp;
	my @line = split;
	@line = map {$_ =~ s/>//; $_} @line;
	push(@arr, $line[0]);
#$hash{$line[0]} = 0;
}
close LIST;

open FA, "$ARGV[1]" || die $!;
$/ = "\n>";
while(<FA>){
	s/>//g;
	my @tag = split /\n/;
	my $id = (split /\s+/, $tag[0])[0];
	$hash{$id} = $_;
#print ">" if(exists $hash{$tag[0]});
#print if(exists $hash{$tag[0]});
}
close FA;

for(my $i = 0; $i <= $#arr; $i++){
	print ">$hash{$arr[$i]}";
}
