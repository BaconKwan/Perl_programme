#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "perl $0 <fa_faidx> <sorted_gtf> <type> <extend_len> <annot_file> <ssr_file> > out_file\n" unless(@ARGV eq 6);

my (%chr,%annot);

open LEN, "$ARGV[0]" || die $!;
while(<LEN>){
	chomp;
	my @line = split /\t/;
	$chr{$line[0]}{len} = $line[1];
}
close LEN;

open GTF, "awk \'\$3 == \"$ARGV[2]\"\' $ARGV[1] |" || die $!;
while(<GTF>){
	chomp;
	my @line = split /\t/;
#$line[3] = $line[3] - $ARGV[3];
#$line[4] = $line[4] + $ARGV[3];
#$line[3] = 1 if($line[3] < 1);
#$line[4] = $chr{$line[0]}{len} if($line[4] > $chr{$line[0]}{len});
	my ($geneid) = $line[8] =~ /gene_id "([^;]+)";/;
	push(@{$chr{$line[0]}{region}}, $line[3], $line[4], $geneid);
#print "$_\n";
#print "$line[3]\t$line[4]\t$geneid\n";
}
close GTF;

open ANNOT, "$ARGV[4]" || die $!;
<ANNOT>;
while(<ANNOT>){
	chomp;
	my @line = split /\t/;
	my $id = shift(@line);
	$annot{$id} = join "\t", @line;
}
close ANNOT;

open SSR, "$ARGV[5]" || die $!;
<SSR>;
my $chr = "xxx";
print "Chr\tSSR\tSize\tStart\tEnd\tEnsembl Gene ID\tPosition\tAssociated Gene Name\tDescription\n";
while(<SSR>){
	chomp;
	my @line = split /\t/;
	if($chr ne $line[0]){
		delete($chr{$chr}) if(exists $chr{$chr});
		$chr = $line[0];
	}
	my $flag = 0;
	if(exists $chr{$line[0]}{region}){
		for(my $i = 0; $i < @{$chr{$line[0]}{region}} / 3; ++$i){
			my $pos = $i * 3;
			my $start = ${$chr{$line[0]}{region}}[$pos] - $ARGV[3];
			my $end = ${$chr{$line[0]}{region}}[$pos+1] + $ARGV[3];
			if($line[5] > $end){
				shift(@{$chr{$line[0]}{region}});shift(@{$chr{$line[0]}{region}});shift(@{$chr{$line[0]}{region}});
				--$i;
				next;
			}
			if($line[6] < $start){
				last if($flag > 0);
				my $txt = join "\t", $line[0], @line[3..6], "-";
				print "$txt\n";
				last;
			}
			elsif($line[6] >= ${$chr{$line[0]}{region}}[$pos] && $line[5] <= ${$chr{$line[0]}{region}}[$pos+1]){
				my $txt = join "\t", $line[0], @line[3..6], ${$chr{$line[0]}{region}}[$pos+2], "intragenic", $annot{${$chr{$line[0]}{region}}[$pos+2]};
				print "$txt\n";
				$flag++;
			}
			elsif($line[6] >= $start && $line[6] < ${$chr{$line[0]}{region}}[$pos]){
				my $txt = join "\t", $line[0], @line[3..6], ${$chr{$line[0]}{region}}[$pos+2], "upstream", $annot{${$chr{$line[0]}{region}}[$pos+2]};
				print "$txt\n";
				$flag++;
			}
			elsif($line[5] <= $end && $line[5] > ${$chr{$line[0]}{region}}[$pos+1]){
				my $txt = join "\t", $line[0], @line[3..6], ${$chr{$line[0]}{region}}[$pos+2], "downstream", $annot{${$chr{$line[0]}{region}}[$pos+2]};
				print "$txt\n";
				$flag++;
			}
		}
	}
	else{
		my $txt = join "\t", $line[0], @line[3..6], "-";
		print "$txt\n";
	}
#print "$_\n";
}
close SSR;
