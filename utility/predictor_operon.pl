#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Math::CDF qw(pbinom);

die "
	perl $0 <gff3> <cov>

" unless(2 == @ARGV);

## ==================== search linear region, push gene into the region & search break interval
my (%gene, %cov, %bre, %re);
my ($flag, $q, $cnt);

open GFF, "< $ARGV[0]" || die $!;
my $init_line = <GFF>;
chomp $init_line;
my @init_line = split /\t/, $init_line;
$init_line[8] =~ s/^\s+gene_id "(\S+)"; .*$/$1/;
$flag = $init_line[6];
$cnt = 1;
$q = $init_line[8];
$gene{$q} = "$init_line[3]|$init_line[4]|$init_line[6]";
push(@{$re{$cnt}{list}}, $q);
$re{$cnt}{pone} = $init_line[6];

open OUT, "> break.txt" || die $!;
while(<GFF>){
	chomp;
	my @line = split /\t/;
	$line[8] =~ s/^\s+gene_id "(\S+)"; .*$/$1/;
	if(exists $gene{$line[8]}){
		my ($a, $b, $c) = split /\|/, $gene{$line[8]};
		my @tmp = sort ($a, $b, $line[3], $line[4]);
		my ($ss, $es) = ($tmp[0], $tmp[-1]);
	}
	if($flag eq $line[6] || $flag eq "na"){
		$flag = $line[6];
		$re{$cnt}{pone} = $line[6];
		$q = $line[8];
		$gene{$q} = "$line[3]|$line[4]|$line[6]";
		push(@{$re{$cnt}{list}}, $q);
	}
	else{
		my ($a, $b, $c) = split /\|/, $gene{$q};
		if($b < $line[3]){
			$flag = $line[6];
			$q = $line[8];
			$gene{$q} = "$line[3]|$line[4]|$line[6]";
			$cnt++;
			push(@{$re{$cnt}{list}}, $q);
			$re{$cnt}{pone} = $line[6];
		}
		else{
			$flag = "na";
			pop(@{$re{$cnt}{list}});
			if(0 != @{$re{$cnt}{list}}){
				$cnt++;
			}
			$bre{$a} = 1;
			$bre{$line[4]} = 1;
			print OUT "$a\t$line[4]\n"; ## debug
		}
	}
}
close OUT;
close GFF;

## ==================== rebulid coverage file
$cnt = 1;

open WIG, "< $ARGV[1]" || die $!;
open OUT, "> all.cov" || die $!;
while(<WIG>){
	chomp;
	my @line = split /\t/;
	next unless(@line eq 2);
	while($cnt < $line[0]){
		$cov{$cnt} = 0.0;
		print OUT "$cnt\t0.0\n";
		$cnt++;
	}
	$cov{$line[0]} = $line[1];
	print OUT "$line[0]\t$line[1]\n";
	$cnt++;
}
close OUT;
close WIG;

## ==================== establish region range by the first & last gene location

open OUT, "> region.txt" || die $!;
foreach my $i (sort {$a <=> $b} keys %re){
	my $start = (split /\|/, $gene{$re{$i}{list}[0]})[0];
	my $end = (split /\|/, $gene{$re{$i}{list}[-1]})[1];
	my $tmp1 = (split /\|/, $gene{$re{$i}{list}[0]})[2];
	my $tmp2 = (split /\|/, $gene{$re{$i}{list}[-1]})[2];
	@{$re{$i}{region}} = ($start, $end);
	my $list = join ";", @{$re{$i}{list}};
	print OUT "$i\t$start\t$end\t$tmp1\t$tmp2\t$re{$i}{pone}\t$list\n";
}
close OUT;

## ==================== extend upstream & downstream of each region
my @site = sort {$a <=> $b} keys %cov;
my ($min, $max);

open OUT, "> filter.region.txt" || die $!;
foreach my $i (sort {$a <=> $b} keys %re){
	my ($start, $end) = @{$re{$i}{region}};
	my ($gs, $ge) = ($start, $end);
	if(exists $re{$i-1}){
		$min = $re{$i-1}{region}[1];
	}
	else{
		$min = 2;
	}
	if(exists $re{$i+1}){
		$max = $re{$i+1}{region}[0];
	}
	else{
		$max = @site - 2;
	}
	while($start >= $min){
		last if((0 == $cov{$start-2}) || ($cov{$start-1} < 2));
		my $sum1 = $cov{$start} + $cov{$start-1};
		my $sum2 = $cov{$start} + $cov{$start-2};
		my $pv1 = pbinom($cov{$start-1}, $sum1, 0.5);
		my $pv2 = pbinom($cov{$start-2}, $sum2, 0.5);
		my $ratio1 = $cov{$start} / $cov{$start-1};
		my $ratio2 = $cov{$start} / $cov{$start-2};
		if($pv1 < 0.01 && $ratio1 >= 2){
			last;
		}
		if($pv2 < 0.01 && $ratio2 >= 2){
#$start--;
			last;
		}
		if(exists $bre{$start}){
			$start = $gs;
			last;
		}
		elsif($start == $min){
			$start = $gs;
			$re{$i-1}{region}[1] = (split /\|/, $gene{$re{$i-1}{list}[-1]})[1] if (exists $re{$i-1});
			last;
		}
		$start--;
	}
	while($end <= $max){
		last if((0 == $cov{$end+2}) || ($cov{$end+1} < 2));
		my $sum1 = $cov{$end} + $cov{$end+1};
		my $sum2 = $cov{$end} + $cov{$end+2};
		my $pv1 = pbinom($cov{$end+1}, $sum1, 0.5);
		my $pv2 = pbinom($cov{$end+2}, $sum2, 0.5);
		my $ratio1 = $cov{$end} / $cov{$end+1};
		my $ratio2 = $cov{$end} / $cov{$end+2};
		if($pv1 < 0.01 && $ratio1 >= 2){
			last;
		}
		if($pv2 <0.01 && $ratio2 >= 2){
#$end++;
			last;
		}
		if(exists $bre{$end}){
			$end = $ge;
			last;
		}
		elsif($end == $max){
			$end = $ge;
			$re{$i+1}{region}[0] = (split /\|/, $gene{$re{$i+1}{list}[0]})[0] if (exists $re{$i+1});
			last;
		}
		$end++;
	}
	@{$re{$i}{region}} = ($start, $end);
	print OUT "$i\t$start\t$end\t$re{$i}{pone}\n"; ## debug
}
close OUT;

## ==================== expend upstream & downstream of each gene in the region

foreach my $i (sort {$a <=> $b} keys %re){
	my $ac_cnt = 1;
	my @id = @{$re{$i}{list}};
	my $gene = shift(@id);
	push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
	@{$re{"$i-$ac_cnt"}{region}} = (split /\|/, $gene{$gene})[0..1];
	$re{"$i-$ac_cnt"}{region}[0] = $re{$i}{region}[0];
	$re{"$i-$ac_cnt"}{pone} = $re{$i}{pone};

	my ($pmin, $pmax) = @{$re{"$i-$ac_cnt"}{region}};

	while($gene = shift(@id)){
		my ($nmin, $nmax) = (split /\|/, $gene{$gene})[0..1];
		my ($pp, $pn) = ($pmax, $nmin);
		while($pp<$nmin){
			last if(($cov{$pp+1} < 2) || (0 == $cov{$pp+2}));
			my $sum1 = $cov{$pp} + $cov{$pp+1};
			my $sum2 = $cov{$pp} + $cov{$pp+2};
			my $pv1 = pbinom($cov{$pp+1}, $sum1, 0.5);
			my $pv2 = pbinom($cov{$pp+2}, $sum2, 0.5);
			my $ratio1 = $cov{$pp} / $cov{$pp+1};
			my $ratio2 = $cov{$pp} / $cov{$pp+2};
			if($pv1 < 0.01 && $ratio1 >= 2){
				last;
			}
			if($pv2 < 0.01 && $ratio2 >= 2){
#$pp++;
				last;
			}
			$pp++;
		}
		while($pn>$pmax){
			last if(($cov{$pn-1} < 2) || (0 == $cov{$pn-2}));
			my $sum1 = $cov{$pn} + $cov{$pn-1};
			my $sum2 = $cov{$pn} + $cov{$pn-2};
			my $pv1 = pbinom($cov{$pn-1}, $sum1, 0.5);
			my $pv2 = pbinom($cov{$pn-2}, $sum2, 0.5);
			my $ratio1 = $cov{$pn} / $cov{$pn-1};
			my $ratio2 = $cov{$pn} / $cov{$pn-2};
			if($pv1 < 0.01 && $ratio1 >= 2){
				last;
			}
			if($pv2 < 0.01 && $ratio2 >= 2){
#$pn--;
				last;
			}
			$pn--;
		}
		if($pp >= $nmin && $pn <= $pmax){
			$re{"$i-$ac_cnt"}{region}[1] = $nmax;
			$pmax = $nmax;
			push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
		}
		elsif($pp >= $nmin && $pn > $pmax){
			$re{"$i-$ac_cnt"}{region}[1] = $pmax;
			$ac_cnt++;
			push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
			@{$re{"$i-$ac_cnt"}{region}} = (split /\|/, $gene{$gene})[0..1];
			$re{"$i-$ac_cnt"}{region}[0] = $pn;
			$re{"$i-$ac_cnt"}{pone} = $re{$i}{pone};
			($pmin, $pmax) = @{$re{"$i-$ac_cnt"}{region}};
		}
		elsif($pn <= $pmax && $pp < $nmin){
			$re{"$i-$ac_cnt"}{region}[1] = $pp;
			$ac_cnt++;
			push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
			@{$re{"$i-$ac_cnt"}{region}} = (split /\|/, $gene{$gene})[0..1];
			$re{"$i-$ac_cnt"}{region}[0] = $nmin;
			$re{"$i-$ac_cnt"}{pone} = $re{$i}{pone};
			($pmin, $pmax) = @{$re{"$i-$ac_cnt"}{region}};
		}
		else{
			if($pp < $pn){
			$re{"$i-$ac_cnt"}{region}[1] = $pp;
			$ac_cnt++;
			push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
			@{$re{"$i-$ac_cnt"}{region}} = (split /\|/, $gene{$gene})[0..1];
			$re{"$i-$ac_cnt"}{region}[0] = $pn;
			$re{"$i-$ac_cnt"}{pone} = $re{$i}{pone};
			($pmin, $pmax) = @{$re{"$i-$ac_cnt"}{region}};
			}
			else{
			$re{"$i-$ac_cnt"}{region}[1] = $pmax;
			$ac_cnt++;
			push(@{$re{"$i-$ac_cnt"}{list}}, $gene);
			@{$re{"$i-$ac_cnt"}{region}} = (split /\|/, $gene{$gene})[0..1];
			$re{"$i-$ac_cnt"}{region}[0] = $nmin;
			$re{"$i-$ac_cnt"}{pone} = $re{$i}{pone};
			($pmin, $pmax) = @{$re{"$i-$ac_cnt"}{region}};
			}
		}
	}
	$re{"$i-$ac_cnt"}{region}[1] = $re{$i}{region}[1];
	delete $re{$i};
}

## ==================== output the result

open OUT, "> operon.txt" || die $!;
print OUT "OperonID\tO_startSite\tO_endSite\tstrand\tavg_cov\t5UTR\t3UTR\tNum\tGeneList\n";
foreach my $i (sort {$re{$a}{region}[0] <=> $re{$b}{region}[0]}keys %re){
	my ($start, $end) = @{$re{$i}{region}};
	my $sum = 0;
	for(my $j = $start; $j <= $end; $j++){
		$sum += $cov{$j};
	}
	my $avg = $sum / ($end - $start + 1);
	if($avg < 3){
		delete $re{$i}{region};
		delete $re{$i}{list};
		delete $re{$i}{pone};
		next;
	}
	$avg = sprintf "%.2f", $avg;
	my ($gstart, $gend) = ((split /\|/, $gene{$re{$i}{list}[0]})[0], (split /\|/, $gene{$re{$i}{list}[-1]})[1]);
	my $genelist = join ";", @{$re{$i}{list}};
	my $num = @{$re{$i}{list}};
	my $pone = $re{$i}{pone};
	my ($_5utr, $_3utr);
	if($pone eq "+"){
		if(abs($start - $gstart) <= 1){
			$_5utr = "*";
		}
		else{
			$_5utr = $start . "-" . ($gstart - 1);
		}
		if(abs($end - $gend) <= 1){
			$_3utr = "*";
		}
		else{
			$_3utr = ($gend + 1) . "-" . $end;
		}
	}
	else{
		if(abs($end - $gend) <= 1){
			$_5utr = "*";
		}
		else{
			$_5utr = ($gend + 1) . "-" . $end;
		}
		if(abs($start - $gstart) <= 1){
			$_3utr = "*";
		}
		else{
			$_3utr = $start . "-" . ($gstart - 1);
		}
	}
	print OUT "$i\t$start\t$end\t$pone\t$avg\t$_5utr\t$_3utr\t$num\t$genelist\n";
}
close OUT;
