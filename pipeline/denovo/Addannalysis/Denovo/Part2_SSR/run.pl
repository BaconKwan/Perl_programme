#!usr/bin/perl -w
use strict;

die "<input denovo name> <sample name>" unless @ARGV==2;
my $denovo = shift;
my $sample = shift;

`mkdir -p SSR_out`;
`ln -s ../../pipe/$denovo/assembly/2.Unigene/$sample-Unigene.fa`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/cut_id.pl $sample-Unigene.fa > SSR_out/$sample-Unigene.fa.cut`;
`cd SSR_out/ && perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/2_SSR/transcriptome_run_ssr.pl $sample-Unigene.fa.cut`;
