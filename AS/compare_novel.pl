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

my ($sample1, $sample2, $sensitivity) = @ARGV;
my (%hash);

open IN, "$sample1" || die $!;
$sample1 = basename($sample1, ".novel");
while(<IN>){
	next if($. == 1);
	chomp;
	my @line = split /\t/;
	my ($chr, $block_s, $as_s, $as_e, $block_e) = ($1, $2, $3, $4, $5) if($line[4] =~ /(\S+):(\d+),(\d+)-(\d+),(\d+)/);
	my $info = join "\t", $line[0], $line[1], $line[2];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{j_id} = $line[3];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{pos} = $line[4];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{as_len} = $line[6];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{reads} = $line[7];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{as_den} = $line[8];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample1}{mark} = 0;
}
close IN;

open IN, "$sample2" || die $!;
$sample2 = basename($sample2, ".novel");

my $out_detail = $sample1 . "-vs-" . $sample2 . "\.novel.diff.xls";
my $out_brief = $sample1 . "-vs-" . $sample2 . "\.novel.diff.brief.xls";
open DETAIL, "> $out_detail" || die $!;
print DETAIL "Gene_ID\tGene_symbol\tTranscript_ID\tStrand\tSample1_junction_id\tSample2_junction_id\tSample1_junction_position\tSample2_junction_position\tSample1_junction_length\tSample2_junction_length\tSample1_junction_count\tSample2_junction_count\tSample1_junction_density\tSample2_junction_density\tlog2_FC\ttype\n";
open BRIEF, "> $out_brief" || die $!;
print BRIEF "Sample1_junction_id\tSample2_junction_id\tSample1_junction_position\tSample2_junction_position\tSample1_junction_density\tSample2_junction_density\tlog2_FC\ttype\n";

while(<IN>){
	next if($. == 1);
	chomp;
	my @line = split /\t/;
	my ($chr, $block_s, $as_s, $as_e, $block_e) = ($1, $2, $3, $4, $5) if($line[4] =~ /(\S+):(\d+),(\d+)-(\d+),(\d+)/);
	my ($probe_ss, $probe_se, $probe_es, $probe_ee) = ($as_s - $sensitivity, $as_s + $sensitivity, $as_e - $sensitivity, $as_e + $sensitivity);
	my $info = join "\t", $line[0], $line[1], $line[2];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{j_id} = $line[3];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{pos} = $line[4];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{as_len} = $line[6];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{reads} = $line[7];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{as_den} = $line[8];
	$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{mark} = 0;

	foreach my $site_1 ($probe_ss..$probe_se){
		foreach my $site_2 ($probe_es..$probe_ee){
			if(exists $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}){
#print "$hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{j_id}\t$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{j_id}\n" if($site_1 != $as_s || $site_2 != $as_e);
				$hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{mark}++;
				$hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{mark}++;
				my $fc = log($hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{as_den} / $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{as_den}) / log(2);

				my $part1 = $info;
				my $part2 = join "\t", $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{j_id}, $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{j_id}, $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{pos}, $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{pos}, $line[5];
				my $part3 = join "\t", $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{as_len}, $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{as_len}, $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{reads}, $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{reads};
				my $part4 = join "\t", $hash{$line[9]}{$chr}{$line[5]}{$site_1}{$site_2}{$info}{$sample1}{as_den}, $hash{$line[9]}{$chr}{$line[5]}{$as_s}{$as_e}{$info}{$sample2}{as_den}, $fc, $line[9]; 
				print DETAIL "$part1\t$part2\t$part3\t$part4\n";
				print BRIEF "$part2\t$part4\n";
			}
		}
	}
}
close IN;

foreach my $type (sort keys %hash){
	foreach my $chr (sort keys %{$hash{$type}}){
		foreach my $strand (sort keys %{$hash{$type}{$chr}}){
			foreach my $as_s (sort {$a <=> $b} keys %{$hash{$type}{$chr}{$strand}}){
				foreach my $as_e (sort {$a <=> $b} keys %{$hash{$type}{$chr}{$strand}{$as_s}}){
					foreach my $info (sort keys %{$hash{$type}{$chr}{$strand}{$as_s}{$as_e}}){
						if(exists $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}){
							next if($hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{mark} > 0);
							my $part1 = $info;
							my $part2 = join "\t", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{j_id}, "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{pos}, "-", $strand;
							my $part3 = join "\t", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{as_len}, "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{reads}, "-";
							my $part4 = join "\t", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample1}{as_den}, "-", "notest", $type;
							print DETAIL "$part1\t$part2\t$part3\t$part4\n";
							print BRIEF "$part2\t$part4\n";
						}
						if(exists $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}){
							next if($hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{mark} > 0);
							my $part1 = $info;
							my $part2 = join "\t", "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{j_id}, "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{pos}, $strand;
							my $part3 = join "\t", "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{as_len}, "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{reads};
							my $part4 = join "\t", "-", $hash{$type}{$chr}{$strand}{$as_s}{$as_e}{$info}{$sample2}{as_den}, "notest", $type;
							print DETAIL "$part1\t$part2\t$part3\t$part4\n";
							print BRIEF "$part2\t$part4\n";
						}
					}
				}
			}
		}
	}
}
close DETAIL;
close BRIEF;

`sort -u $out_brief > $out_brief.tmp && mv $out_brief.tmp $out_brief -f`;
