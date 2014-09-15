#!usr/bin/perl-w
use strict;
my ($l_10,$l_50,$l_100,$l_200,$l_300,$l_400,$l_500,$l_1000,$l_10000,$l_large);
# Infile should be soap-coverage output file!
open(A,shift);
<A>;
print "Number of Reads\tNumber of Unigenes\n";
while(<A>)
{
	chomp;
	my @a=split(/\t/);
	$l_10++ if ($a[6]>=0 && $a[6]<=10);
	$l_50++ if ($a[6]>10 && $a[6]<=50);
	$l_100++ if ($a[6]>50 && $a[6]<=100);
	$l_200++ if ($a[6]>100 && $a[6]<=200);
	$l_300++ if ($a[6]>200 && $a[6]<=300);
	$l_400++ if ($a[6]>300 && $a[6]<=400);
	$l_500++ if ($a[6]>400 && $a[6]<=500);
	$l_1000++ if ($a[6]>500 && $a[6]<=1000);
	$l_10000++ if ($a[6]>1000 && $a[6]<=10000);
	$l_large++ if ($a[6]>10000);
}
close A;
print "1-10\t$l_10\n";
print "11-50\t$l_50\n";
print "51-100\t$l_100\n";
print "101-200\t$l_200\n";
print "201-300\t$l_300\n";
print "301-400\t$l_400\n";
print "401-500\t$l_500\n";
print "501-1000\t$l_1000\n";
print "1001-10000\t$l_10000\n";
print ">10000\t$l_large\n";
