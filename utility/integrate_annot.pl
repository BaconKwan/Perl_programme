#!/usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 26, 2014
#	Usage:	
use warnings;
use utf8;
use strict;

die
"
	Use this programme to integrate all annotation information form blast result(nr, swissprot, cog, kegg).
	Usage: perl $0 <fa> <gtf> <blast.Nr.xls> <blast.Swissprot.xls> <cog.gene.annot.xls> <pathway> <blast.kegg.xls> <outprefix>

"if(@ARGV ne 8);

my %hash;

## Reading fasta file
open FA, "$ARGV[0]" || die $!;
$/ = "\n>";
while(<FA>){
	s/>//g;
	my @line = split;
	$line[1] =~ s/gene=//;
	$hash{$line[0]}{fa} = $line[1];
}
$/ = "\n";
close FA;

## Reading gtf file
open GTF, "$ARGV[1]" || die $!;
while(<GTF>){
	chomp;
	my @line = split /\t/;
	if(/transcript_id "([^;]+)"/){
		push(@{$hash{$1}{gtf}}, "$line[0]:$line[3]:$line[4]");
	}
}
close GTF;

## Reading blast.Nr.xls
open NR,"$ARGV[2]" || die $!;
while(<NR>){
	chomp;
	my @line = split /\t/;
	next if(exists $hash{$line[0]}{nr});
	$hash{$line[0]}{nr} = $line[$#line];
}
close NR;

## Reading blast.Swissport.xls
open SWISS, "$ARGV[3]" || die $!;
while(<SWISS>){
	chomp;
	my @line = split /\t/;
	next if(exists $hash{$line[0]}{swiss});
	if($line[$#line] =~ /\s+GN=/){
		$hash{$line[0]}{swiss} = $`;
	}
	elsif($line[$#line] =~ /\s+PE=/){
		$hash{$line[0]}{swiss} = $`;
	}
	elsif($line[$#line] =~ /\s+SV=/){
		$hash{$line[0]}{swiss} = $`;
	}
	else{
		$hash{$line[0]}{swiss} = $line[$#line];
	}
}
close SWISS;

## Reading cog.gene.annot.xls
open COG, "$ARGV[4]" || die $!;
<COG>;
while(<COG>){
	chomp;
	my @line = split /\t/;
	next if(exists $hash{$line[0]}{cog});
	$line[7] =~ s/\s*;//;
	$hash{$line[0]}{cog} = "$line[5]\t$line[7]";
}
close COG;

## Reading path file
open PATH,"$ARGV[5]" || die $!;
<PATH>;
while(<PATH>){
	chomp;
	my @line = split /\t/;
	my @trans = split /;/, $line[3];
	foreach my $id (@trans){
		push(@{$hash{$id}{path}}, $line[0]);
	}
}
close PATH;

## Reading kegg.xls
open KEGG, "$ARGV[6]" || die $!;
while(<KEGG>){
	chomp;
	my @line = split /\t/;
	next if(exists $hash{$line[0]}{kegg});
	$hash{$line[0]}{kegg} = $line[12];
}
close KEGG;
## Output
## Print header
open OUT, "> $ARGV[7].annot.xls" || die $!;
print OUT "gene_id\ttranscript_id\tlocus\texon_number\tgene_length\tnr_description\tswissprot_description\tcog_function_description\tcog_functional_categories\tpathways\tkegg_description\n";
foreach my $trans_id (sort keys %hash){
	## Print GeneID & transcriptID
	print OUT "$hash{$trans_id}{fa}\t$trans_id";
	## Add gtf info
	if(exists $hash{$trans_id}{gtf}){
		my $exon_num = @{$hash{$trans_id}{gtf}};
		my @parts = split /:/, pop(@{$hash{$trans_id}{gtf}});
		my $chromosome = $parts[0];
		my $start = $parts[1];
		my $end = $parts[2];
		my $len = $end - $start + 1;
		foreach(@{$hash{$trans_id}{gtf}}){
			@parts = split /:/;
			$len += $parts[2] - $parts[1] + 1;
			$end = $parts[2] if($parts[2] > $end);
			$start = $parts[1] if($parts[1] < $start);
		}
		print OUT "\t$chromosome:$start-$end\t$exon_num\t$len";
	}
	else{
		print OUT "\t--\t--\t--";
	}
	## Add nr info
	if (exists $hash{$trans_id}{nr}){
		print OUT "\t$hash{$trans_id}{nr}";
	}
	else{
		print OUT "\t--";
	}
	## Add Swissport info
	if (exists $hash{$trans_id}{swiss}){
		print OUT "\t$hash{$trans_id}{swiss}";
	}
	else{
		print OUT "\t--";
	}
	## Add cog info
	if (exists $hash{$trans_id}{cog}){
		print OUT "\t$hash{$trans_id}{cog}";
	}
	else{
		print OUT "\t--\t--";
	}
	## Add path info
	if (exists $hash{$trans_id}{path}){
		my $paths = join "; ", @{$hash{$trans_id}{path}};
		print OUT "\t$paths";
	}
	else{
		print OUT "\t--";
	}
	## Add kegg info
	if (exists $hash{$trans_id}{kegg}){
		print OUT "\t$hash{$trans_id}{kegg}";
	}
	else{
		print OUT "\t--";
	}
	## Line wrap
	print OUT "\n";
}
