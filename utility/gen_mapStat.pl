#! /usr/bin/perl

use utf8;
use strict;
use warnings;

die "perl $0 <bam> <reads_len>\n" unless(@ARGV eq 2);

my $total_reads = 0;
my $total_base = 0;
my $total_mapReads = 0;
my $total_uniqReads = 0;
my $total_multiReads = 0;
my $perfect_match = 0;
my $lt2bp_match = 0;
my $total_unmapReads = 0;
open BAM, "samtools view $ARGV[0] |" || die $!;
while(my $info = <BAM>){
	chomp $info;
	my @line = split /\t/, $info;
	my @base = split //, $line[9];
	my $base = @base;
	if($line[2] ne "*"){
		if($info =~ /(MD:\S+)/){
			my @part = split /\:/, $1;
			my $mis_match = ($part[2] =~ tr/AaTtCcGgNn/AaTtCcGgNn/);
			if(0 == $mis_match){
				$perfect_match++;
			}
			elsif(2 >= $mis_match){
				$lt2bp_match++;
			}
		}
		$total_uniqReads++;
		$total_mapReads++;
	}
	$total_reads++;
	$total_base += $base;
}
close BAM;

$total_multiReads = $total_mapReads - $total_uniqReads;
$total_unmapReads = $total_reads - $total_mapReads;

my $ratio_base = 100 * $total_base / ($total_reads * $ARGV[1]);
$ratio_base = sprintf("%.2f%%", $ratio_base);
my $ratio_map = 100 * $total_mapReads / $total_reads;
$ratio_map = sprintf("%.2f%%", $ratio_map);
my $ratio_perfect = 100 * $perfect_match / $total_reads;
$ratio_perfect = sprintf("%.2f%%", $ratio_perfect);
my $ratio_lt2bp = 100 * $lt2bp_match / $total_reads;
$ratio_lt2bp = sprintf("%.2f%%", $ratio_lt2bp);
my $ratio_uniq = 100 * $total_uniqReads / $total_reads;
$ratio_uniq = sprintf("%.2f%%", $ratio_uniq);
my $ratio_multi = 100 * $total_multiReads / $total_reads;
$ratio_multi = sprintf("%.2f%%", $ratio_multi);
my $ratio_unmap = 100 * $total_unmapReads / $total_reads;
$ratio_unmap = sprintf("%.2f%%", $ratio_unmap);

print "Map to Gene\treads number\tpercentage";
print "Total Reads:\t$total_reads\t100.00%\n";
print "Total BasePairs:\t$total_base\t$ratio_base\n";
print "Total Mapped Reads:\t$total_mapReads\t$ratio_map\n";
print "perfect match:\t$perfect_match\t$ratio_perfect\n";
print "<=2bp mismatch:\t$lt2bp_match\t$ratio_lt2bp\n";
print "unique match:\t$total_uniqReads\t$ratio_uniq\n";
print "multi-position match:\t$total_multiReads\t$ratio_multi\n";
print "Total Unmapped Reads:\t$total_unmapReads\t$ratio_unmap\n";
