#!/usr/bin/perl -w
use strict;
#use Data::Dumper;
use File::Basename;

die "Usage:perl $0 <infile>" unless @ARGV == 1;

open IN,$ARGV[0] || die "can't open the file";
my %hash;
my $total;
my $length;
my @target;
my ($G_number,$C_number,$N_number) = (0)x3;
my $total_size = 0;
my $total_number_200 = 0;
my $total_number_2k = 0;
my $total_number_1k = 0;
my $length_cutoff = 100;
my $N_value = 50;
$/=">",<IN>;$/="\n";
while(<IN>)
{
	chomp;
	my $seq;
	$/=">";
	$seq .= <IN>;
	$/="\n";
	$seq =~s/>//g;
	$seq =~s/\s+//g;
	$length = length($seq);
	$G_number += ($seq =~ s/G/G/ig);
	$C_number += ($seq =~ s/C/C/ig);
	$N_number += ($seq =~ s/N/N/ig);
	$total_size += $length;
	if($length>=200)
	{
		$total_number_200++;
	}
	if($length>=2000)
	{
		$total_number_2k++;
	}
	if($length>=1000)
	{
		$total_number_1k++;
	}
	if($length >= $length_cutoff)
	{
		push @target,$length;
		$hash{$length}++;
		$total+=$length;
	}
	
}

my $GC_ratio = 100*($G_number+$C_number)/($total_size-$N_number);
my $mean_length=int($total_size/$total_number_200);
my $sum;
my $Number;
@target = sort {$b<=>$a} @target;
print "Max_length:$target[0]\tMin_length:$target[-1]\tmean_length:$mean_length\ntotal_size:$total_size\ttotal_number_200:$total_number_200\ttotal_number_1k:$total_number_1k\ttotal_number_2k:$total_number_2k\nG:$G_number\tC:$C_number\tN:$N_number\nGC ratio:$GC_ratio\n";
print "N value\tsize\tnumber\n";
for my $element (@target)
{
	$sum += $element;
	if($sum >= $total/100*$N_value)
	{
		for(my $i = $element;$i <= $target[0];$i++)
		{
			$Number += $hash{$i} if exists $hash{$i};
		}
		print "N$N_value\t$element\t$Number\n";
		$N_value+=10;
		$Number = 0;
		last if $N_value == 100;
	}
}

close IN;
