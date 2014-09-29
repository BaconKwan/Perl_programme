#!/usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 26, 2014
#	Usage:	
use warnings;
use utf8;
use strict;
use Getopt::Long;

my %opts;
GetOptions (\%opts, "i=s", "sa=i", "fc=f", "p=f", "s=i");
&usage if(!$opts{i} || !$opts{sa});
$opts{fc}=$opts{fc}?$opts{fc}:1;
$opts{p}=$opts{p}?$opts{p}:0.01;
$opts{s}=$opts{s}?$opts{s}:0;
$opts{s}=$opts{s}>=1?1:0;

open IN, "< $opts{i}" || die $!;
open OUT, "> $opts{i}.diffgene.xls" || die $!;
my $head = <IN>;
print OUT "$head";
while(<IN>){
	chomp;
	my @line = split;
	my $fc_pos = $opts{sa} + 3;
	my $value_pos = $fc_pos + 1 + $opts{s};
	next if($line[$fc_pos] eq "NA");
	print OUT "$_\n" if($opts{fc} < abs($line[$fc_pos]) && $opts{p} > $line[$value_pos]);
}
close OUT;
close IN;

sub usage{
	print "
	Usage:	perl $0 -i <input_file> -sa <number> [options]
	Options:
		-i      file    input file usually RPKM Ttest.xls or AOV.xls
		-sa     int     total sample amount
		-fc     float   FC value for filter, default 1
		-p      float   P value for filter, default 0.01
		-s      int     0 -- use P value, 1 -- use fdr value

";
	exit;
}
