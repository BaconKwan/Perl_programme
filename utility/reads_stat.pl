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
	Usage: perl $0 <Gene.rpkm.xls>

" if(@ARGV < 1);

foreach my $file (@ARGV){
	
	my $total_reads;
	
	open IN, "< $file" || die $!;
	open OUT, "> $file.high_exp" || die $!;
	my $line = <IN>;
	chomp $line;
	$total_reads = $1 if($line =~ /Uniq_reads_num\((\d+)\)/i);
	while(<IN>){
		chomp;
		my @line = split /\t/;
		my $per = ( $line[1] / $total_reads ) * 100;
		printf OUT "%s\t%d\t%.2f%%\n", $line[0], $line[1], $per;
	}
	close OUT;
	close IN;
	
}
