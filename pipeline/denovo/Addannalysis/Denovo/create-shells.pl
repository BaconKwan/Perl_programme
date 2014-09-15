#!usr/bin/perl-w
use strict;

die "Usage: Perl $1 <Denovo name> <Sample name>\n" unless @ARGV==2;
my $denovo=shift;
my $sample=shift;

open(OUT1,">Part1_assembly_annot/run_part1.sh");
print OUT1 "perl run_v2.pl $denovo\n";

open(OUT2,">Part2_SSR/run_part2.sh");
print OUT2 "perl run.pl $denovo $sample\n";


open(OUT4,">Part4_pfam/run_part4.sh");
print OUT4 "perl run.pl $denovo $sample\n";

