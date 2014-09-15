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
GetOptions (\%opts, "i=s", "t=s", "a=s", "b=s", "r=i");
&usage if(!$opts{i} || !$opts{t} || !$opts{a} || !$opts{b} || !$opts{r});

my %hash;

open TEST, "< $opts{t}" || die $!;
<TEST>;
while(<TEST>){
	chomp;
	my @line = split /\t/;
	$hash{$line[0]}{control} = $line[$opts{r}*2+1];
	$hash{$line[0]}{case} = $line[$opts{r}*2+2];
	$hash{$line[0]}{logfc} = $line[$opts{r}*2+3];
	$hash{$line[0]}{pvalue} = $line[$opts{r}*2+4];
	$hash{$line[0]}{fdr} = $line[$opts{r}*2+5];
}
close TEST;

open ALL, "< $opts{i}" || die $!;
open GDE, "> $opts{a}-VS-$opts{b}.GeneDiffExp.xls" || die $!;
open GDEF, "> $opts{a}-VS-$opts{b}.GeneDiffExpFilter.xls" || die $!;
my $head = <ALL>;
my @head = split /\t/, $head;
my $a_post = 0;
my $b_post = 0;
for(my $i = 2; $i <= $#head - 4; $i++){
	if($head[$i] =~ /$opts{a}/){
		$a_post = $i;
		$i += $opts{r} * 3 -1;
	}
	elsif($head[$i] =~ /$opts{b}/){
		$b_post = $i;
		$i += $opts{r} * 3 -1;
	}
}
print GDE "GeneID\tGene_length\t$opts{a}-Expression\t$opts{b}-Expression\t$opts{a}-RPKM\t$opts{b}-RPKM\tlog2 Ratio($opts{b}/$opts{a})\tUp-Down-Regulation($opts{b}/$opts{a})\tP-value\tFDR\tDescription\tPathway\tGO Component\tGO Function\tGO Process\n";
print GDEF "GeneID\tGene_length\t$opts{a}-Expression\t$opts{b}-Expression\t$opts{a}-RPKM\t$opts{b}-RPKM\tlog2 Ratio($opts{b}/$opts{a})\tUp-Down-Regulation($opts{b}/$opts{a})\tP-value\tFDR\tDescription\tPathway\tGO Component\tGO Function\tGO Process\n";
while(<ALL>){
	chomp;
	my @line = split /\t/;
	my $a_reads = 0;
	my $b_reads = 0;
	my $UD;
	next if($hash{$line[0]}{logfc} eq "NA");
	for(my $i = 0; $i <= $opts{r} - 1; $i++){
		$line[$a_post + $i * 3] = 0 if($line[$a_post + $i * 3] eq "-");
		$line[$b_post + $i * 3] = 0 if($line[$b_post + $i * 3] eq "-");
		$a_reads += $line[$a_post + $i * 3];
		$b_reads += $line[$b_post + $i * 3];
	}
	$a_reads = int($a_reads/$opts{r});
	$b_reads = int($b_reads/$opts{r});
	if(exists $hash{$line[0]}{logfc}){
		$UD = $hash{$line[0]}{logfc}>=0?"Up":"Down";
		print GDE "$line[0]\t$line[1]\t$a_reads\t$b_reads\t$hash{$line[0]}{control}\t$hash{$line[0]}{case}\t$hash{$line[0]}{logfc}\t$UD\t$hash{$line[0]}{pvalue}\t$hash{$line[0]}{fdr}\t$line[$#line - 4]\t$line[$#line - 3]\t$line[$#line - 2]\t$line[$#line - 1]\t$line[$#line]\n";
		print GDEF "$line[0]\t$line[1]\t$a_reads\t$b_reads\t$hash{$line[0]}{control}\t$hash{$line[0]}{case}\t$hash{$line[0]}{logfc}\t$UD\t$hash{$line[0]}{pvalue}\t$hash{$line[0]}{fdr}\t$line[$#line - 4]\t$line[$#line - 3]\t$line[$#line - 2]\t$line[$#line - 1]\t$line[$#line]\n" if(abs($hash{$line[0]}{logfc}) > 1 && $hash{$line[0]}{pvalue} < 0.01);
	}
}

close GDEF;
close GDE;
close ALL;

sub usage{
	print "
	Usage:	perl $0 -i <all.gene.rpkm.xls> -t <Ttest.xls> -a <case_tag> -b <control_tag> -r <duplicates>
	Options:
		-i    file        input file all.gene.rpkm.xls from pipeline usually locate in ../pipe/upload/GeneExp
		-t    file        input file statistical analysis result file, which is formated like 
		                  <GeneID>\\t<control_RPKM>..<case_RPKM>...\\t<control_mean>\\t<case_mean>\\t<log2_FC>\\t<pvlaue>\\t<fdr>
		-a    string      case group name
		-b    string      control group name
		-r    int         duplicates in control/case group (duplicates of each group must be the same)
";
	exit;
}
