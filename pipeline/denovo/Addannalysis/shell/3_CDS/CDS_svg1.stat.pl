#!usr/bin/perl-w
use strict;
open IN,shift;
my $more=0;
my $equal=0;
my $less=0;
	my ($r0,$r5,$r7,$r9,$r11);
while(<IN>)
{
	chomp;
	next if($_=~/^#/);
	my @a=split(/\t/);
	$more++ if ($a[1]>1);
	$equal++ if($a[1]==1);
	$less++ if($a[1]<1);

	$r0++ if($a[1]<0.5);
	$r5++ if($a[1]>=0.5 && $a[1]<0.7);
	$r7++ if($a[1]>=0.7 && $a[1]<0.9);
	$r9++ if($a[1]>=0.9 && $a[1]<1.1);
	$r11++ if($a[1]>=1.1);
}
close IN;
print "Ratio of Unigene length/ortholog length\tCount\n";
print ">1\t$more\n";
print "=1\t$equal\n";
print "<1\t$less\n";
print "Detailed statistic of length/length Ratio distribution:\n";
print "Ratio<0.5\t$r0\n";
print "0.5<=Ratio<0.7\t$r5\n";
print "0.7<=Ratio<0.9\t$r7\n";
print "0.9<=Ratio<1.1\t$r9\n";
print "Ratio>=1.1\t$r11\n";
