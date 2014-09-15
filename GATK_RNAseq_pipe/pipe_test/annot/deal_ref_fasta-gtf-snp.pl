#!/usr/bin/env perl
use warnings;
use strict;

die "	perl $0 <fasta> <gtf> <outprefix>
Note:
	make sure you have authority to write into disk
	dealed fasta contain /^[0-9XYxy]+\$/ chrs
	dealed gtf is same to dealed fasta and sorted by start and end
\n" if @ARGV != 3;

my ($fa, $gtf, $op) = @ARGV;

if(-s "$op.fa")
{
	print STDERR "fasta is existent\n";
}else{
print STDERR "fasta processing...[1/6]\n";
open FAO, "> $op.fa" or die $!;
$/ = "\n>";
open FA, $fa or die $!;
while(<FA>)
{
	chomp;
	s/^>//;
	my @lines = split /\n/;
	my @c = split /\s+/, $lines[0];
	if($c[0] =~ /^Chr[0-9XYxyCcMm]+$/)
	{
		print FAO ">$_\n";
	}
}
$/ = "\n";
}

if(-s "$op.fa.fai")
{
print STDERR "samtools index is existent\n";
}else{
print STDERR "samtools index processing...[2/6]\n";
`samtools faidx $op.fa`;
}

if(-s "$op.dict")
{
print STDERR "picard index is existent\n";
}else{
print STDERR "picard index processing...[3/6]\n";
`java -jar /home/guanpeikun/tools/picard-tools-1.115/CreateSequenceDictionary.jar R=$op.fa O=$op.dict`;
}

my @chrs;
open SFI, "$op.fa.fai" or die $!;
while(<SFI>)
{
	chomp;
	my @t = split;
	push @chrs, $t[0];
}

if(-s "$op.gtf")
{
print STDERR "gtf is existent\n";
}else{
print STDERR "gtf processing...[4/6]\n";
my %gse;
open GTF, $gtf or die $!;
while(<GTF>)
{
	chomp;
	next if(/^#/);
	my @tmp = split;
	next if($tmp[1] !~ /SpliceGrapher/);
	push @{$gse{$tmp[0]}{$tmp[3]}{$tmp[4]}}, $_;
}

open GTFO, "> $op.gtf" or die $!;
foreach(@chrs)
{
	foreach my $i(sort {$a<=>$b} keys %{$gse{$_}})
	{
		foreach my $j(sort {$a<=>$b} keys %{$gse{$_}{$i}})
		{
			print GTFO join "\n", @{$gse{$_}{$i}{$j}};
			print GTFO "\n";
		}
	}
}
}

if(-s "$op.bed")
{
print STDERR "12bed is existent\n";
}else{
print STDERR "gtf to 12bed processing...[5/6]\n";
`perl /home/sunyong/bin/gtf2bed.pl $op.gtf gene > $op.bed`;
}

if(-s "${op}_refGene.txt" or -s "${op}_refGeneMrna.fa")
{
print STDERR "2refGene is existent\n";
}else{
print STDERR "gtf to genepred processing...[6/6]\n";
`gffread $op.gtf -o $op.gff`;
`sed -i 1d $op.gff`;
`/home/sunyong/bin/gff3ToGenePred $op.gff $op.genepred`;
`awk '{print 1"\t"\$0}' $op.genepred > ${op}_refGene.txt`;
`perl /home/sunyong/bin/annovar/retrieve_seq_from_fasta.pl -format refGene -seqfile $op.fa --outfile ${op}_refGeneMrna.fa ${op}_refGene.txt`;
}

print STDERR "all done!\n";
