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
	perl $0 <input.bam> <output_prefix>
"unless( 2 == @ARGV );

open INBAM, "samtools view -h $ARGV[0] |" || die $!;
open OUT, ">", "$ARGV[1].sam" || die $!;
open NDN, "> $ARGV[1]_bad.sam" || die $!;
while(<INBAM>){
	chomp;
	if(/^@/){
		print OUT "$_\n";
		print NDN "$_\n";
		next;
	}
	my @line = split /\t/;
	if($line[5] =~ /\d+N\d+D\d+N/){
		print NDN "$_\n";
	}
	else{
		print OUT "$_\n";
	}
}
close NDN;
close OUT;
close INBAM;

`samtools view -b $ARGV[1].sam > $ARGV[1].bam && rm $ARGV[1].sam -rf`
`samtools view -b $ARGV[1]_bad.sam > $ARGV[1]_bad.bam && rm $ARGV[1]_bad.sam -rf`
