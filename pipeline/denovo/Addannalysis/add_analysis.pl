#! /usr/bin/perl -w

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 25, 2014
#	Usage:	create Add_analysis running shells

use utf8;
use strict;

die"Usage: perl $0 <Denovo name> <Sample name>\n" unless 2 == @ARGV;

my $denovo = shift;
my $sample = shift;

`mkdir -p Add_analysis`;
`mkdir -p Add_analysis/Part1_assembly_annot`;
`mkdir -p Add_analysis/Part2_SSR`;
`mkdir -p Add_analysis/Part3_CDS`;
`mkdir -p Add_analysis/Part4_pfam`;

open OUT1, "> Add_analysis/Part1_assembly_annot/run_part1.sh";
print OUT1 "perl run_v2.pl $denovo\n";
close OUT1;
`ln -sf /home/luoyue/Pls/RNA_add/pipe_model/Add_analysis_upload/Part1_assembly_annot/run_v2.pl ./Add_analysis/Part1_assembly_annot/run_v2.pl`;

open OUT2, "> Add_analysis/Part2_SSR/run_part2.sh";
print OUT2 "perl run.pl $denovo $sample\n";
close OUT2;
`ln -sf /home/luoyue/Pls/RNA_add/pipe_model/Add_analysis_upload/Part2_SSR/run.pl ./Add_analysis/Part2_SSR/run.pl`;

open OUT3, "> Add_analysis/Part3_CDS/run_part3.sh";
print OUT3 "perl /home/luoyue/Pls/RNA_add/pipe_model/Programs_for_denovo_add/3_CDS/before_run.pl $denovo $sample\n";
print OUT3 "nohup perl /home/luoyue/Pls/RNA_add/pipe_model/Programs_for_denovo_add/3_CDS/run.pl 1st_Nr_species $denovo $sample &\n";
print OUT3 "nohup perl /home/luoyue/Pls/RNA_add/pipe_model/Programs_for_denovo_add/3_CDS/run.pl 2nd_Nr_species $denovo $sample &\n";
print OUT3 "nohup perl /home/luoyue/Pls/RNA_add/pipe_model/Programs_for_denovo_add/3_CDS/run.pl 3rd_Nr_species $denovo $sample &\n";
close OUT3;

open OUT4, "> Add_analysis/Part4_pfam/run_part4.sh";
print OUT4 "perl run.pl $denovo $sample\n";
close OUT4;
`ln -sf /home/luoyue/Pls/RNA_add/pipe_model/Add_analysis_upload/Part4_pfam/run.pl ./Add_analysis/Part4_pfam/run.pl`;

`cp -rf /home/luoyue/Pls/RNA_add/pipe_model/Add_analysis_upload/tar.sh Add_analysis/`;
`ln -sf /home/luoyue/Pls/RNA_add/pipe_model/Add_analysis_upload/generate_xlsx_for_denovo.pl Add_analysis/generate_xlsx_for_denovo.pl`;

print "\nstrongly recommed finish this work as the following step:\n";
print "finish Part1, Part2 & Part4 by running run_part#.sh in each folders.\n";
print "finish Part3 in final. Before run the shell script, you must select the top 3 species in the Nr.species.stat.xls and make sure that you have downloaded the genome files.\n";
print "After that, the genome file(*.fa) must be cut id and rename in a correct way.\n\n";
