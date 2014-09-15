#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "
	usage: perl $0 <list> <bed>

" unless(@ARGV eq 2);

my @list;
my %hash;

open LIST, "< $ARGV[0]" || die $!;
while(<LIST>){
	chomp;
	my @line = split /\t/;
	push(@list, $line[0]);
}
close LIST;

open BED, "< $ARGV[1]" || die $!;
while(<BED>){
	chomp;
	my @line = split /\t/;
	$hash{$line[3]} = $_;
}
close BED;

foreach my $id (@list){
	print "$hash{$id}\n" if(exists $hash{$id});
}
