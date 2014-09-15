#!usr/bin/perl -w
use strict;

if (@ARGV != 2)
{
	print "Usage: perl $0 <denovo name>\n";die;
}

my $denovo = shift;
my $sample = shift;

`mkdir -p data`;
`mkdir -p result`;
`ln -s ../../../pipe/$denovo/CDS/$sample-Unigene.blast.protein.fa data/`;
`ln -s ../../../pipe/$denovo/CDS/$sample-Unigene.ESTscan.protein.fa data/`;
`cat data/$sample-Unigene.blast.protein.fa data/$sample-Unigene.ESTscan.protein.fa > data/$sample-Unigene.protein.fa`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/cut_id.pl data/$sample-Unigene.protein.fa > data/$sample-Unigene.protein.fa.cut`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/PfamScan/pfam_scan.pl -fasta data/$sample-Unigene.protein.fa.cut -dir /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/PfamScan/Data -cpu 10 > result/$sample-Unigene.protein.fa.cut.pfamA`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/PfamScan/pfam_result_change.pl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/PfamScan/Data/Pfam-A.hmm.dat result/$sample-Unigene.protein.fa.cut.pfamA > result/$sample-Unigene.protein.fa.cut.pfamA.name`;
