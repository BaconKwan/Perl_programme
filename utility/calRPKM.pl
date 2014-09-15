#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	Usage: perl $0 <rpkmList>
	rpkmList file should be formated as: <Qname>\\t<Rname>\\t<length>\\t<match>\\t<mismatch>

"if(@ARGV != 1);

open IN , '<' , $ARGV[0];

my %rpkm_hash;
my $maped_reads_cnt = 0;
my $key;

while(<IN>){
	my @text = split /\t/, $_;
	$key = $text[1];

	#%rpkm_hash = (%rpkm_hash,$key => [0,0]) if (!(exists $rpkm_hash{$key}));
	$rpkm_hash{$key}[0] += 1;
	$rpkm_hash{$key}[1] = $text[2];
	$maped_reads_cnt += 1;
}

close IN;

open OUT , '>' , "RPKM.xls";
print OUT "ID\tRPKM\tLN\treads_cnt\tratio\n";
foreach $key (sort keys %rpkm_hash){
	my $rpkm_value = ($rpkm_hash{$key}[0] * 10000000000) / ($maped_reads_cnt * $rpkm_hash{$key}[1]); 
	my $ratio = $rpkm_hash{$key}[0]/$maped_reads_cnt;
	print OUT "$key\t$rpkm_value\t$rpkm_hash{$key}[1]\t$rpkm_hash{$key}[0]\t$ratio\n";
}

close OUT;
