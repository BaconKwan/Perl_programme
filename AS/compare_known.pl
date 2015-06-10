#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use File::Basename qw /basename dirname/;

my ($sample1, $sample2) = @ARGV;
my (%trans, %hash);

open IN, "$sample1" || die $!;
$sample1 = basename($sample1, ".known");
while(<IN>){
	next if($. == 1);
	chomp;
	my @line = split /\t/;
	my ($chr, $block_s, $as_s, $as_e, $block_e) = ($1, $2, $3, $4, $5) if($line[4] =~ /(\S+):(\d+),(\d+)-(\d+),(\d+)/);
	$trans{$line[2]}{gene_id} = $line[0] unless(exists $trans{$line[2]}{gene_id});
	$trans{$line[2]}{gene_name} = $line[1] unless(exists $trans{$line[2]}{gene_name});
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample1}{j_id} = $line[3];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample1}{pos} = $line[4];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample1}{as_len} = $line[6];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample1}{reads} = $line[7];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample1}{as_den} = $line[8];
}
close IN;

open IN, "$sample2" || die $!;
$sample2 = basename($sample2, ".known");
while(<IN>){
	next if($. == 1);
	chomp;
	my @line = split /\t/;
	my ($chr, $block_s, $as_s, $as_e, $block_e) = ($1, $2, $3, $4, $5) if($line[4] =~ /(\S+):(\d+),(\d+)-(\d+),(\d+)/);
	$trans{$line[2]}{gene_id} = $line[0] unless(exists $trans{$line[2]}{gene_id});
	$trans{$line[2]}{gene_name} = $line[1] unless(exists $trans{$line[2]}{gene_name});
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample2}{j_id} = $line[3];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample2}{pos} = $line[4];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample2}{as_len} = $line[6];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample2}{reads} = $line[7];
	$hash{$chr}{$as_s}{$as_e}{$line[5]}{$line[2]}{$sample2}{as_den} = $line[8];
}
close IN;

my $out_detail = $sample1 . "-vs-" . $sample2 . "\.known.diff.xls";
my $out_brief = $sample1 . "-vs-" . $sample2 . "\.known.diff.brief.xls";
open DETAIL, "> $out_detail" || die $!;
print DETAIL "Gene_ID\tGene_symbol\tTranscript_ID\tStrand\tSample1_junction_id\tSample2_junction_id\tSample1_junction_position\tSample2_junction_position\tSample1_junction_length\tSample2_junction_length\tSample1_junction_count\tSample2_junction_count\tSample1_junction_density\tSample2_junction_density\tlog2_FC\n";
open BRIEF, "> $out_brief" || die $!;
print BRIEF "Sample1_junction_id\tSample2_junction_id\tSample1_junction_position\tSample2_junction_position\tSample1_junction_density\tSample2_junction_density\tlog2_FC\n";
foreach my $chr (sort keys %hash){
	foreach my $as_s (sort keys %{$hash{$chr}}){
		foreach my $as_e (sort keys %{$hash{$chr}{$as_s}}){
			foreach my $sign (sort keys %{$hash{$chr}{$as_s}{$as_e}}){
				foreach my $t_id (sort keys %{$hash{$chr}{$as_s}{$as_e}{$sign}}){
					my $g_id = $trans{$t_id}{gene_id};
					my $g_name = $trans{$t_id}{gene_name};
					my $fc = "fc";
					unless(exists $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}){
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{j_id} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{pos} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{as_len} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{reads} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{as_den} = "-";
						$fc = "notest";
					}
					unless(exists $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}){
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{j_id} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{pos} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{as_len} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{reads} = "-";
						$hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{as_den} = "-";
						$fc = "notest";
					}
					unless($fc eq "notest"){
						$fc = log($hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{as_den} / $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{as_den}) / log(2);
					}
					my $part1 = join "\t", $g_id, $g_name, $t_id, $sign;
					my $part2 = join "\t", $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{j_id}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{j_id}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{pos}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{pos};
					my $part3 = join "\t", $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{as_len}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{as_len}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{reads}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{reads};
					my $part4 = join "\t", $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample1}{as_den}, $hash{$chr}{$as_s}{$as_e}{$sign}{$t_id}{$sample2}{as_den}, $fc;
					print DETAIL "$part1\t$part2\t$part3\t$part4\n";
					print BRIEF "$part2\t$part4\n";
				}
			}
		}
	}
}
close DETAIL;
close BRIEF;

`uniq $out_brief > $out_brief.tmp && mv $out_brief.tmp $out_brief -f`;
