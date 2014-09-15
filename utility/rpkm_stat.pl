#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Getopt::Long;

my %opts;
GetOptions(\%opts, "in=s", "rpkm=f", "reads=i");
die"
	Usage: perl $0 <rpkm> [rpkm_threshold] [reads_threshold]
	Options:
		-in        file        input file, for example: rpkm.xls
		-rpkm      float       rpkm threshold of filter which can be counted as eligibility
		-reads     int         reads threshold of filter which can be counted as eligibility

" if(!$opts{in});

my @count;
if($opts{rpkm} && $opts{reads}){
	&rpkm_reads;
}
elsif($opts{rpkm} && !$opts{reads}){
	&rpkm;
}
elsif($opts{reads} && !$opts{rpkm}){
	&reads;
}
else{
	$opts{rpkm}=0.01;
	&rpkm;
}

sub rpkm_reads{
	open RPKM, "< $opts{in}" || die $!;
	<RPKM>;
	while(<RPKM>){
		chomp;
		my @line = split;
		$count[0]++;
		$count[1]++ if($line[2] < $opts{reads} && $line[3] < $opts{rpkm});
	}
	close RPKM;
	print "total:\t\t$count[0]\n";
	my $p = ($count[1] / $count[0]) * 100;
	printf("rpkm < %.2f & reads < %d\n%d\t\t%.2f%%\n", $opts{rpkm}, $opts{reads}, $count[1], $p);
}
sub rpkm{
	open RPKM, "< $opts{in}" || die $!;
	<RPKM>;
	while(<RPKM>){
		chomp;
		my @line = split;
		$count[0]++;
		$count[1]++ if($line[3] < $opts{rpkm});
	}
	close RPKM;
	print "total:\t\t$count[0]\n";
	my $p = ($count[1] / $count[0]) * 100;
	printf("rpkm < %.2f\n%d\t\t%.2f%%\n", $opts{rpkm}, $count[1], $p);
}

sub reads{
	open RPKM, "< $opts{in}" || die $!;
	<RPKM>;
	while(<RPKM>){
		chomp;
		my @line = split;
		$count[0]++;
		$count[1]++ if($line[2] < $opts{reads});
	}
	close RPKM;
	print "total:\t\t$count[0]\n";
	my $p = ($count[1] / $count[0]) * 100;
	printf("reads < %d\n%d\t\t%.2f%%\n", $opts{reads}, $count[1], $p);
}
