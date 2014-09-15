#!usr/bin/perl -w
use strict;

die "perl $0 <Denovo Name> <Sample Name>" unless @ARGV==2;

my $denovo = shift;
my $sample = shift;

`ln -s ../../pipe/$denovo/CDS/$sample-Unigene.ESTscan.cds.fa ./`;
`ln -s ../../pipe/$denovo/CDS/$sample-Unigene.blast.cds.fa ./`;

`cat $sample-Unigene.blast.cds.fa $sample-Unigene.ESTscan.cds.fa > $sample.cds.fa`;
`perl ~/gaochuan/program/cut_id.pl $sample.cds.fa > $sample.cds.fa.cut`;
`/opt/bio/ncbi/bin/formatdb -i $sample.cds.fa.cut -p F`;
