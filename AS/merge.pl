#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use List::Util qw/max min/;
use List::MoreUtils qw/uniq/;

die "perl $0 <gtf> <known.out> <novel.out> <sense>\n" unless(@ARGV eq 4);

my (%hash, %rpkm, %gene, %stat);

open GTF, "$ARGV[0]" || die $!;
while(<GTF>){
	chomp;
	my @line = split /\t/;
	next unless($line[2] eq "exon");
	my ($chr, $site1, $site2, $sign, $gene_name) = ($line[0], $line[3], $line[4], $line[6], "-");
	my $info = pop(@line);
	my ($gene_id) = $info =~ /gene_id "([^;]+)";/;
	my ($transcript_id) = $info =~ /transcript_id "([^;]+)";/;
	$gene_name = $1 if($info =~ /gene_name "([^;]+)";/);

	$hash{$chr}{$transcript_id}{sign} = $sign;
	$hash{$chr}{$transcript_id}{gene_name} = $gene_name;
	$hash{$chr}{$transcript_id}{gene_id} = $gene_id;

	$gene{$chr}{$gene_id}{sign} = $sign;
	$gene{$chr}{$gene_id}{gene_name} = $gene_name;
	push(@{$gene{$chr}{$gene_id}{transcript_id}}, $transcript_id);

	($site1, $site2) = ($site2, $site1) if($site1 > $site2);
	if($sign eq "+"){
		push(@{$hash{$chr}{$transcript_id}{exons}}, $site1);
		push(@{$hash{$chr}{$transcript_id}{exons}}, $site2);
		if(!exists $gene{$chr}{$gene_id}{exons} || @{$gene{$chr}{$gene_id}{exons}} eq 0){
			push(@{$gene{$chr}{$gene_id}{exons}}, $site1);
			push(@{$gene{$chr}{$gene_id}{exons}}, $site2);
		}
		else{
			if(${$gene{$chr}{$gene_id}{exons}}[-1] >= $site1 && ${$gene{$chr}{$gene_id}{exons}}[-2] <= $site1){
				my @s = (${$gene{$chr}{$gene_id}{exons}}[-1], ${$gene{$chr}{$gene_id}{exons}}[-2], $site1, $site2);
				my $min = min(@s);
				my $max = max(@s);
				${$gene{$chr}{$gene_id}{exons}}[-2] = $min;
				${$gene{$chr}{$gene_id}{exons}}[-1] = $max;
			}
			else{
				push(@{$gene{$chr}{$gene_id}{exons}}, $site1);
				push(@{$gene{$chr}{$gene_id}{exons}}, $site2);
			}
		}
	}
	else{
		unshift(@{$hash{$chr}{$transcript_id}{exons}}, $site1);
		unshift(@{$hash{$chr}{$transcript_id}{exons}}, $site2);
		if(!exists $gene{$chr}{$gene_id}{exons} || @{$gene{$chr}{$gene_id}{exons}} eq 0){
			unshift(@{$gene{$chr}{$gene_id}{exons}}, $site1);
			unshift(@{$gene{$chr}{$gene_id}{exons}}, $site2);
		}
		else{
			if(${$gene{$chr}{$gene_id}{exons}}[0] >= $site1 && ${$gene{$chr}{$gene_id}{exons}}[1] <= $site1){
				my @s = (${$gene{$chr}{$gene_id}{exons}}[0], ${$gene{$chr}{$gene_id}{exons}}[1], $site1, $site2);
				my $min = min(@s);
				my $max = max(@s);
				${$gene{$chr}{$gene_id}{exons}}[0] = $max;
				${$gene{$chr}{$gene_id}{exons}}[1] = $min;
			}
			else{
				unshift(@{$gene{$chr}{$gene_id}{exons}}, $site1);
				unshift(@{$gene{$chr}{$gene_id}{exons}}, $site2);
			}
		}
	}
}
close GTF;

foreach my $c (%gene){
	foreach my $ge (%{$gene{$c}}){
		@{$gene{$c}{$ge}{transcript_id}} = uniq(@{$gene{$c}{$ge}{transcript_id}});
	}
}

open KNOWN, "$ARGV[1]" || die $!;
while(<KNOWN>){
	chomp;
	my @line = split /\t/;
}
close KNOWN;
