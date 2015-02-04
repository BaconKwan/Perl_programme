#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use File::Basename qw/basename/;

my %hash;
my @file;

while(my $file = shift){
	open IN, "< $file" || die $!;
	$file = basename($file, ".Gene.rpkm.xls");
	push(@file, $file);
	<IN>;
	while(<IN>){
		chomp;
		my @txt = split /\t/;
		$hash{$txt[0]}{$file} = $txt[4];
	}
	close IN;
}

print "GeneID";
foreach my $i (sort @file){
	print "\t$i";
}
print "\n";
foreach my $i (sort keys %hash){
	print "$i";
	foreach my $j (sort @file){
		if(exists $hash{$i}{$j}){
			print "\t$hash{$i}{$j}";
		}
		else{
			print "\t-";
		}
	}
	print "\n";
}
close ;
